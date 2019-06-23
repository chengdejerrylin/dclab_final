import sys
with open(sys.argv[1], "r") as f :
	idx = 0

	for line in f.readlines() :
		print(line[0], end='')
		idx += 1

		if idx == 50 :
			print()
			idx = 0