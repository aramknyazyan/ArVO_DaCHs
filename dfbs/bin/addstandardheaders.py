"""
This script will update the headers of the FBS plate scans with
according to the Tuvikene et al plate archive standard,
https://www.plate-archive.org/wiki/index.php/FITS_header_format

[TODO: Fix the WCS, too]
"""

import warnings
warnings.filterwarnings('ignore', module='astropy.io.fits.verify')

import re
import os

from astropy import wcs
import numpy

from gavo import api
from gavo import base
from gavo import utils
from gavo.base import coords
from gavo.utils import fitstools
from gavo.helpers import fitstricks

_KEYS_PROBABLY_BROKEN = set([
    "OBJCTX", "OBJCTY"])

class PAHeaderAdder(api.HeaderProcessor):
    # PA as in "Plate Archive"

    def _createAuxiliaries(self, dd):
        from urllib import urlencode
        from gavo import votable
        from gavo.stc import jYearToDateTime, dateTimeToMJD

        if os.path.exists("q.cache"):
            f = open("q.cache")
        else:
            f = utils.urlopenRemote("http://dc.g-vo.org/tap/sync", data=urlencode({
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
        return "XXX" in self.getPrimaryHeader(srcName)
    
    def _mungeHeader(self, srcName, hdr):
        for card in hdr.cards:
            card.verify("fix")
            if card.keyword in _KEYS_PROBABLY_BROKEN:
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
        
        if False:
          plateCenter = coords.getCenterFromWCSFields(
            coords.getWCS(hdr))
        else:
          # TODO: when there's either a good WCS header or DaCHS
          # can better deal with DSS calibration, remove this
          # and the "if False" above.
          plateCenter = (meta["raj2000"], meta["dej2000"])

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

if __name__=="__main__":
    api.procmain(PAHeaderAdder, "dfbs/q", "import")

# vim:et:sw=4:sta
