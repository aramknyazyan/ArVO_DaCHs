"""
This script will update the WCS calibration of the DFBS plates from
CSS-style to Calabretta et al style.

It will also clean up the headers to match the Taavi et al scanned plates
convention.
"""

import warnings
warnings.filterwarnings('ignore', module='astropy.io.fits.verify')

from astropy import wcs
import numpy

from gavo import api
from gavo.helpers import fitstricks


class DSSCalibrationFixer(api.HeaderProcessor):
    def _isProcessed(self, srcName):
        return "CD1_1" in self.getPrimaryHeader(srcName)
    
    def _mungeHeader(self, srcName, hdr):
        phys = wcs.WCS(hdr)
        print phys.all_pix2world(numpy.array([[0,1], [0,2000], [0,4000]]), 1)
       

if __name__=="__main__":
    api.procmain(DSSCalibrationFixer, "dfbs/q", "import")

# vim:et:sw=4:sta
