import numpy as np
from skimage import io
from sklearn.cluster import KMeans
import sys
from argparse import ArgumentParser

parser = ArgumentParser(description='A program that convert the bmp picture to hardware format.')
parser.add_argument('pic', help='Input pucture.')
parser.add_argument('-o', dest="out", default="", help='output prefix.')
parser.add_argument('-b', dest="bit", type=int, default=3, help='bits of label.')
parser.add_argument('-no-fix', dest="fix", action="store_false", help='use randome seed.')
parser.add_argument('-d', dest="dither", action="store_true", help='no dithering algorithm.')
parser.add_argument('-m', dest="mode", default="sierra", help='dithering algorithm. \'sierra\', \'JJN\'')

#parse data
args = parser.parse_args()
original = io.imread(args.pic)
n_colors = (1 << args.bit)
seed = 42 if args.fix else None
reductionFile = args.out + "_reduction.jpg"
if not args.out : 
	args.out = args.pic[:-4] + "_" + str(n_colors)
	reductionFile = args.out + "_reduction.jpg"
	if args.dither : args.out += "_" + args.mode

if args.mode == "sierra" : 
	transmission = [[0.0/32, 0.0/32, 0.0/32, 5.0/32, 3.0/32], \
					[2.0/32, 4.0/32, 5.0/32, 4.0/32, 2.0/32], \
					[0.0/32, 2.0/32, 3.0/32, 2.0/32, 0.0/32] ]
if args.mode == "JJN" : 
	transmission = [[0.0/48, 0.0/48, 0.0/48, 7.0/48, 5.0/48], \
					[3.0/48, 5.0/48, 7.0/48, 5.0/48, 3.0/48], \
					[1.0/48, 3.0/48, 5.0/48, 3.0/48, 1.0/48] ]
elif args.dither :
	print("ERROR : no such of dither mode : " + args.mode)
	parser.print_help()
	sys.exit()

print("# of colors : " + str(n_colors))
print("dithering   : " + str(args.dither))
if args.dither :  print("mode        : " + args.mode)
print("----------------------------------")

#color reduction
print("Color reducing...")
arr = original.reshape((-1, 3))
kmeans = KMeans(n_clusters=n_colors, random_state=seed).fit(arr)
labels = kmeans.labels_.copy()
centers = kmeans.cluster_centers_
less_colors = centers[labels].reshape(original.shape).astype('uint8')
io.imsave(reductionFile, less_colors)

#dither
if args.dither :
	print("Color dithering...")
	height, width, _ = original.shape
	arr_dither = original.copy().astype('float64')
	labels = labels.reshape(height, width)

	for h in range(height) :
		for w in range(width) :
			group = kmeans.predict([arr_dither[h][w]] )[0]
			labels[h][w] = group
			error = arr_dither[h][w] - centers[group]

			for n_h in range(3) :
				if h + n_h >= height : break

				for n_w in range(5) :
					if w + n_w  -2 < 0 : continue
					if w + n_w  -2 >= width : break
					arr_dither[h + n_h][w + n_w -2] += transmission[n_h][n_w] * error

	labels = labels.reshape(-1)
	ditherPic = centers[labels].reshape(original.shape).astype('uint8')
	io.imsave(args.out + "_dithering.jpg", ditherPic)


with open(args.out + "_labels.dat", "w") as f :
	digit = 0
	remain = int(args.bit)
	while remain > 0:
		digit = digit +1
		remain = remain -4

	for l in labels :
		f.write(format(int(l), '0' + str(digit) + 'x'))
		f.write("\n")

with open(args.out + "_values.dat", "w") as f :
	for c in centers :
		f.write(format(int(c[0]+0.5), '02x'))
		f.write(format(int(c[1]+0.5), '02x'))
		f.write(format(int(c[2]+0.5), '02x'))
		f.write("\n")