#!/usr/bin/python

import cPickle as pickle
import pprint
import json
import sys

infile = sys.argv[1]
outfile = sys.argv[2]

def main(): #(infile, outfilename):
	file = pickle.load(open(infile, "r"))
	write_to_file(file, outfile)

def write_to_file(something, filename):
	#path = '/ufs/aggelen/HistWords/' + filename
	with open(filename, 'w') as f:
    		json.dump(something, f)

#main("/ufs/aggelen/Downloads/sgns/1900-vocab.pkl", "1900-vocab")
#main("/ufs/aggelen/Downloads/vols.pkl", "vols.json")

main()


