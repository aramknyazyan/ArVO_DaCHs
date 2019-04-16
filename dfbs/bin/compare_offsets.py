# a little helper script computing the offsets in RA and DEC between
# a DSS and a TAN-SIP calibrated image.  Pass in the file names.

import sys

from PIL import Image
from astropy import wcs
import numpy as np
from gavo.utils import pyfits, imgtools


SUBSAMPLE = 5

def get_position_grid(fits_path):
	hdr = pyfits.open(fits_path)[0].header
	trafo = wcs.WCS(hdr)
	row_indices = range(1, hdr["NAXIS2"]+1, SUBSAMPLE)
	grid = np.array([(x, y) 
		for x in row_indices
		for y in range(1, hdr["NAXIS1"]+1, SUBSAMPLE)])
	return len(row_indices), trafo.all_pix2world(grid, 1)


def offsets_to_image(offsets, row_length, dest_name):
	im = offsets/max(offsets)*255
	im = np.reshape(im, (row_length, -1))
	im = imgtools._normalizeForImage(im, 1)
	with open(dest_name, "wb") as f:
		Image.fromarray(im).save(f, format="png")


def main():
	path_old, path_new = sys.argv[1:]
	row_length, pos_old = get_position_grid(path_old)
	# *assuming* row_length is the same
	_, pos_new = get_position_grid(path_new)
	offsets = pos_old-pos_new

	offsets_to_image(offsets[:,0], row_length, "diff_ra.png")
	offsets_to_image(offsets[:,1], row_length, "diff_dec.png")


if __name__=="__main__":
	main()
