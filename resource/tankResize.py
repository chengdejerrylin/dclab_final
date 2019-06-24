import sys
from PIL import Image

im = Image.open(sys.argv[1])
im = im.resize((50,50), Image.NEAREST)
im.save(sys.argv[1][:-4] + '_50x50.bmp')