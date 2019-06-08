from PIL import Image
import sys

im = Image.open(sys.argv[1])
rgb_im = im.convert('RGB')

with open(sys.argv[1] + ".dat", "w") as f :
	for x in xrange(800) :
		for y in xrange(600) :
			r, g, b = rgb_im.getpixel((x, y))
			#print(x, y, r, g, b)
			f.write(hex(r >> 4)[2:])
			f.write(hex(r & 15)[2:])
			f.write(hex(g >> 4)[2:])
			f.write(hex(g & 15)[2:])
			f.write(hex(b >> 4)[2:])
			f.write(hex(b & 15)[2:])
			f.write('\n')
