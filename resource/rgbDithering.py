import numpy as np
from skimage import io
import sys
from argparse import ArgumentParser

parser = ArgumentParser(description='A program that convert the bmp picture to hardware format.')
parser.add_argument('pic', help='Input pucture.')
parser.add_argument('-o', dest="out", default="", help='output prefix.')
parser.add_argument('-m', dest="mode", default="sierra", help='dithering algorithm. \'sierra\', \'JJN\'')

#parse data
args = parser.parse_args()
picture = io.imread(args.pic).astype('float64')
if not args.out : 
	args.out = args.pic[:-4] + "_rgb_" + args.mode

if args.mode == "sierra" : 
	transmission = [[0.0/32, 0.0/32, 0.0/32, 5.0/32, 3.0/32], \
					[2.0/32, 4.0/32, 5.0/32, 4.0/32, 2.0/32], \
					[0.0/32, 2.0/32, 3.0/32, 2.0/32, 0.0/32] ]
if args.mode == "JJN" : 
	transmission = [[0.0/48, 0.0/48, 0.0/48, 7.0/48, 5.0/48], \
					[3.0/48, 5.0/48, 7.0/48, 5.0/48, 3.0/48], \
					[1.0/48, 3.0/48, 5.0/48, 3.0/48, 1.0/48] ]
else :
	print("ERROR : no such of dither mode : " + args.mode)
	parser.print_help()
	sys.exit()
print("mode   : " + args.mode)

#dithering
height, width, _ = picture.shape

with open(args.out + ".dat", "w") as f :
	for h in range(height) :
		for w in range(width) :
			#write
			post = (picture[h][w] > 127) * 255
			rgb = 0
			if post[0] : rgb +=4
			if post[1] : rgb +=2
			if post[2] : rgb +=1
			f.write(str(rgb))
			f.write('\n')

			#calculate error and save data
			for i in picture[h][w] : i = 255 if i > 255 else i
			error = post - picture[h][w]
			picture[h][w] = post

			#dithering
			for n_h in range(3) :
				if h + n_h >= height : break

				for n_w in range(5) :
					if w + n_w  -2 < 0 : continue
					if w + n_w  -2 >= width : break
					picture[h + n_h][w + n_w -2] -= transmission[n_h][n_w] * error

io.imsave(args.out + ".jpg", picture.astype('uint8'))