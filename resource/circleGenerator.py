from argparse import ArgumentParser

parser = ArgumentParser(description='A program that generate circle dat file.')
parser.add_argument('out', help='output dat file.')
parser.add_argument('-W', dest='width', type=int)
parser.add_argument('-H', dest='height', type=int)
parser.add_argument('-R', dest='radius', type=int)

args = parser.parse_args()
centerX = args.width // 2
centerY = args.height // 2
squR = args.radius **2

with open(args.out, 'w') as f :
	for y in range(args.height+1) :
		if y == centerY : continue

		for x in range(args.width+1) :
			if x == centerX : continue
			
			diffX = x - centerX
			diffY = y - centerY
			squDis = diffX **2 + diffY**2
			temp = "1" if squDis <= squR else "0"
			f.write(temp)

		f.write('\n')