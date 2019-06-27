import numpy as np
from skimage import io
import sys

original = io.imread(sys.argv[1])
for x in range(len(original)) :
	for y in range(len(original[x])) :
		if original[x][y][0] >= 16 and original[x][y][1] < 16 and original[x][y][2] < 16 :
			original[x][y] = np.array([original[x][y][2], original[x][y][1], original[x][y][0]])

io.imsave(sys.argv[1][:-4] + '_blue.jpg', original)

