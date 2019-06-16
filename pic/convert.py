import numpy as np
from skimage import io
from sklearn.cluster import KMeans
from argparse import ArgumentParser

parser = ArgumentParser(description='A program that convert the bmp picture to hardware format.')
parser.add_argument('pic', help='Input pucture.')
parser.add_argument('-o', dest="out", default="", help='output prefix.')
parser.add_argument('-b', dest="bit", type=int, default=3, help='bits of label.')
parser.add_argument('-fix', dest="fix", action="store_true", help='fix randome seed.')

args = parser.parse_args()
n_colors = (1 << args.bit)
if not args.out : args.out = args.pic[:-4] + "_" + str(n_colors)
seed = None if args.fix else 42
original = io.imread(args.pic)

arr = original.reshape((-1, 3))
kmeans = KMeans(n_clusters=n_colors, random_state=seed).fit(arr)
labels = kmeans.labels_
centers = kmeans.cluster_centers_
print(centers)
less_colors = centers[labels].reshape(original.shape).astype('uint8')

io.imsave(args.out + "_out.jpg", less_colors)

with open(args.out + ".labels", "w") as f :
	digit = 0
	remain = int(args.bit)
	while remain > 0:
		digit = digit +1
		remain = remain -4

	for l in labels :
		f.write(format(l, '0' + str(digit) + 'x'))
		f.write("\n")

with open(args.out + ".values", "w") as f :
	for c in centers :
		rgb = (int(c[0] + 0.5) << 16 ) + (int(c[0] + 0.5) << 8 ) + int(c[2] + 0.5)
		f.write(format(rgb, '06x'))
		f.write("\n")

