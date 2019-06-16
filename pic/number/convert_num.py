from PIL import Image
import sys
from argparse import ArgumentParser

parser = ArgumentParser(description='A program that convert the bmp picture to hardware format.')
parser.add_argument('pic', help='Input pucture.')
parser.add_argument('-o', dest="out", default="", help='output dat file.')

args = parser.parse_args()
if not args.out : args.out = args.pic[:-4] + ".dat"

im = Image.open(args.pic)
width, height = im.size

with open(args.out, "w") as f :
	for y in range(height) :
		for x in range(width) :
			f.write(str(im.getpixel((x, y))) )

		f.write("\n")