"""
This script will update the headers of the FBS plate scans with
according to the Tuvikene et al plate archive standard,
https://www.plate-archive.org/wiki/index.php/FITS_header_format
"""

import warnings
warnings.filterwarnings('ignore', module='astropy.io.fits.verify')

import datetime
import re
import os
import random
import subprocess

from astropy import wcs
import numpy

from gavo import api
from gavo import base
from gavo import utils
from gavo.base import coords
from gavo.utils import fitstools
from gavo.utils import pyfits
from gavo.helpers import fitstricks

_KEYS_PROBABLY_BROKEN = set([
    "OBJCTX", "OBJCTY"])

_DSS_CALIBRATION_KEYS = [
    "OBJCTRA",
    "OBJCTDEC",
    "OBJCTX",
    "OBJCTY",
    "PPO1",    
    "PPO2",    
    "PPO3",    
    "PPO4",    
    "PPO5",    
    "PPO6",    
    "PLTRAH",  
    "PLTRAM",  
    "PLTRAS",  
    "PLTDECSN",
    "PLTDECD", 
    "PLTDECM", 
    "PLTDECS", 
    "AMDX1",   
    "AMDX2",   
    "AMDX3",   
    "AMDX4",   
    "AMDX5",   
    "AMDX6",   
    "AMDX7",   
    "AMDX8",   
    "AMDX9",   
    "AMDX10",  
    "AMDX11",  
    "AMDX12",  
    "AMDX13",  
    "AMDY1",   
    "AMDY2",   
    "AMDY3",   
    "AMDY4",   
    "AMDY5",   
    "AMDY6",   
    "AMDY7",   
    "AMDY8",   
    "AMDY9",   
    "AMDY10",  
    "AMDY11",  
    "AMDY12",  
    "AMDY13",
    "XPIXELSZ",
    "YPIXELSZ",
    "EQUINOX",
    "CNPIX1",
    "CNPIX2",
    "PLTSCALE",
    "PLTLABEL"]


class PAHeaderAdder(api.HeaderProcessor):
    # PA as in "Plate Archive"

    def _createAuxiliaries(self, dd):
        from urllib import urlencode
        from gavo import votable

        if os.path.exists("q.cache"):
            f = open("q.cache")
        else:
            f = utils.urlopenRemote("http://dc.g-vo.org/tap/sync", 
                data=urlencode({
              "LANG": "ADQL",
              "QUERY": "select *"
                " from wfpdb.main"
                " where object is not null and object!=''"
                "   and instr_id='BYU102A'"
                "   and method='objective prism'"}))
            with open("q.cache", "w") as cache:
                cache.write(f.read())
            f = open("q.cache")

        data, metadata = votable.load(f)

        self.platemeta = {}
        for row in metadata.iterDicts(data):
            plateid = row["object"].replace(" ", "").lower()
            # for the following code, see import_platemeta in q.rd
            if row["object"]=="FBS 0966" and int(row["epoch"])==1974:
              row["object"] = "FBS 0966a"
            if row["object"]=="FBS 0326" and row["epoch"]>1971.05:
              row["object"] = "FBS 0326a"
            if row["object"]=="FBS 0449" and row["epoch"]>1971.38:
              row["object"] = "FBS 0449a"
            self.platemeta[plateid] = row

    def getPrimaryHeader(self, srcName):
        # Some FBS headers have bad non-ASCII in them that confuses pyfits
        # so badly that nothing works.  We have to manually defuse things.
        if os.path.getsize(srcName)==0:
          raise base.SkipThis()
        with open(srcName) as f:
            hdu = fitstools._TempHDU()
            rawBytes = fitstools.readHeaderBytes(f, 40).replace("\001", " ")
            hdu._raw = rawBytes

        hdu._extver = 1  # We only do PRIMARY
        hdu._new = 0
        hdu = hdu.setupHDU()
        return hdu.header

    def _isProcessed(self, srcName):
        return "A_ORDER" in self.getPrimaryHeader(srcName)
    
    def _mungeHeader(self, srcName, hdr):
        for card in hdr.cards:
            card.verify("fix")
            if (card.keyword in _KEYS_PROBABLY_BROKEN 
                    and isinstance(card.rawvalue, basestring)):
                card.value = float(re.sub(" .*", "", card.rawvalue))
           
            if isinstance(card.value, basestring):
                card.value = card.value.strip()
        
        plateid = "fbs"+re.search(
            r"[Ff][Bb][Ss](\d\d\d\d)", srcName).group(1)
        meta = self.platemeta[plateid]
        
        dateOfObs = api.jYearToDateTime(meta["epoch"])

        kws = {}
        if meta["exptime"] is None:
            kws["TMS_ORIG"] = dateOfObs.time().strftime(
                "UT %H:%M")
            kws["TIMEFLAG"] = "uncertain"
            kws["DATE_OBS"] = dateOfObs.date().isoformat()
            # Areg says: it's almost always 20 minutes
            kws["EXPTIME"] = 20*60
        else:
            startOfObs = dateOfObs-datetime.timedelta(
                seconds=meta["exptime"]/2)
            startTime = startOfObs.time()
            endTime = dateOfObs.time()+datetime.timedelta(
                seconds=meta["exptime"]/2)
            kws["TMS_ORIG"] = startTime.strftime("UT %H:%M:%S")
            kws["TME_ORIG"] = endTime.strftime("UT %H:%M:%S")
            kws["EXPTIME"] = meta["exptime"]
            kws["DATE_OBS"] = startOfObs.isoformat()
            kws["DATE_AVG"] = dateOfObs.isoformat()

        if meta["time_problem"]=="Epoch missing":
            kws["TIMEFLAG"] = "missing"
        
        wcsFields = self.compute_WCS(hdr)
        kws.update(wcsFields)
        for kw_name in _DSS_CALIBRATION_KEYS:
            if kw_name in hdr:
                del hdr[kw_name]
#        TODO: Add history

        kws["NAXIS1"], kws["NAXIS2"] = hdr["NAXIS1"], hdr["NAXIS2"]
        plateCenter = coords.getCenterFromWCSFields(kws)

        hdr = fitstricks.makeHeaderFromTemplate(
            fitstricks.WFPDB_TEMPLATE,
            originalHeader=hdr,
            DATEORIG=dateOfObs.date().isoformat(),
            RA_ORIG=utils.degToHms(meta["raj2000"], ":"),
            DEC_ORIG=utils.degToDms(meta["dej2000"], ":"),
            OBJECT=meta["object"],
            OBJTYPE=meta["object_type"],
            NUMEXP=1,
            OBSERVAT="Byurakan Astrophysical Observatory",
            SITELONG=44.2917,
            SITELAT=40.1455,
            SITEELEV=1490,
            TELESCOP=hdr["TELESCOP"],
            TELAPER=1,
            TELFOC=2.13,
            TELSCALE=96.8,
            INSTRUME=hdr["INSTRUME"],
            DETNAM="Photographic Plate",
            METHOD=meta["method"],
            PRISMANG='1:30',
            DISPERS=2000,
            NOTES=meta["notes"],

            PLATENUM=plateid,
            WFPDB_ID=meta["wfpdbid"],
            SERIES="FBS",
            PLATEFMT="16x16",
            PLATESZ1=16,
            PLATESZ2=16,
            FOV1=4.1,
            FOV2=4.1,
            EMULSION=meta["emulsion"],

            RA=utils.degToHms(plateCenter[0]),
            DEC=utils.degToDms(plateCenter[1]),
            RA_DEG=plateCenter[0],
            DEC_DEG=plateCenter[1],

            YEAR_AVG=meta["epoch"],
            SCANRES1=1600,
            SCANRES2=1600,
            PIXSIZE1=15.875,
            PIXSIZE2=15.875,
            SCANAUTH="Areg Mickaelian",

            ORIGIN="Byurakan",

            **kws)
            
        return hdr

    def compute_WCS(self, hdr):
        """returns a modern WCS header for anything astropy.WCS can deal
        with.

        This uses fit-wcs from astrometry.net.
        """
        # Create a sufficient number of x,y <-> RA, Dec pairs based on the
        # existing calibration.
        ax1, ax2 = hdr["NAXIS1"], hdr["NAXIS2"]
        mesh = numpy.array([
                (random.random()*ax2, random.random()*ax1) 
                for i in range(1000)])
        trafo = wcs.WCS(hdr)
        transformed = trafo.all_pix2world(mesh, 1)

        # Make a FITS input for fit-wcs from that data
        pyfits.HDUList([
            pyfits.PrimaryHDU(),
            pyfits.BinTableHDU.from_columns(
                pyfits.ColDefs([
                    pyfits.Column(name="FIELD_X", format='E', array=mesh[:,0]),
                    pyfits.Column(name="FIELD_Y", format='E', array=mesh[:,1]),
                    pyfits.Column(name="INDEX_RA", format='E', 
                        array=transformed[:,0]),
                    pyfits.Column(name="INDEX_DEC", format='E', 
                        array=transformed[:,1]),
                ]))]
            ).writeto("correspondence.fits", clobber=1)
        
        # run fits-wcs and slurp in the headers it generates
        subprocess.check_call(["fit-wcs", "-s2", 
            "-c", "correspondence.fits", "-o", "newcalib.fits"])
        with open("newcalib.fits", "rb") as f:
            newHeader = fitstools.readPrimaryHeaderQuick(f)
        
        return newHeader

if __name__=="__main__":
    api.procmain(PAHeaderAdder, "dfbs/q", "import")

# vim:et:sw=4:sta
