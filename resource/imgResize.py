import sys
from PIL import Image

im = Image.open(sys.argv[1])

if float(im.size[1]) / im.size[0] == 9.0/16.0 :
	w, h = im.size
	im = im.crop((w*2.0/16.0, 0, w*14.0/16.0, h))
	im.save(sys.argv[1][:-4] + '_crop.jpg')

im = im.resize((320,220), Image.NEAREST)
im.save(sys.argv[1][:-4] + '_320x220.bmp')