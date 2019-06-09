from PIL import Image
import sys
from argparse import ArgumentParser

parser = ArgumentParser(description='A program that convert the picture to hardware format.')
parser.add_argument('pic', help='Input pucture.')
parser.add_argument('-o', dest="out", default="", help='output dat file.')
parser.add_argument('-H', dest="h", type=int, default=800,  help='Horizontal of the picture.')
parser.add_argument('-V', dest="v", type=int, default=600,  help='Vertical of the picture.')
parser.add_argument('-m', dest="mode", default="relu16",  help='Mode of encoding. normal/relu/relu16')

args = parser.parse_args()
if not args.out : args.out = args.pic + ".dat"
if args.mode == "normal" : 
	func = lambda pixel: hex(pixel[0] >> 4)[2:] + hex(pixel[0] & 15)[2:] + \
						 hex(pixel[1] >> 4)[2:] + hex(pixel[1] & 15)[2:] + \
						 hex(pixel[2] >> 4)[2:] + hex(pixel[2] & 15)[2:] + '\n'
elif args.mode == "relu" : 
	func = lambda pixel: ("1" if pixel[0] > 127 else "0") + \
						 ("1" if pixel[1] > 127 else "0") + \
						 ("1" if pixel[2] > 127 else "0") + '\n'
elif args.mode == "relu16" : 
	func = lambda pixel: ("1" if pixel[0] > 16 else "0") + \
						 ("1" if pixel[1] > 16 else "0") + \
						 ("1" if pixel[2] > 16 else "0") + '\n'
else :
	print("ERROR : Invalid Mode \"" + args.mode + "\"")
	sys.exit()

im = Image.open(args.pic)
rgb_im = im.convert('RGB')

with open(args.out, "w") as f :
	for x in range(args.h) :
		for y in range(args.v) :
			f.write(func(rgb_im.getpixel((x, y)) ) )
