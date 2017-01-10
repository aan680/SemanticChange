#!/usr/bin/python

import sys
import cPickle as pickle
import pprint
import json

pkl_input = sys.argv[1]
file_words = sys.argv[2]
file_years = sys.argv[3]
file_values = sys.argv[4]

#e.g. ./pkl_to_json.py ../source/vols_EN.pkl "consec-words" "consec-years" "consec-values"
#e.g. ./pkl_to_json.py ../source/disps_EN.pkl "vsnow-words" "vsnow-years" "vsnow-values"

def main():
        data = open(pkl_input, "r")
        words, years, values = unpack(data)
        write_to_file(words, file_words) #words
        write_to_file(years, file_years) #years
        write_to_file(values, file_values) #values


def unpack(filestream):
        stats = pickle.load(filestream)
        words =  [x.encode('UTF8') for x in stats.keys()] #values are dictionaries with years as keys and numbers as columns. 
	years =  [x.keys() for x in stats.values()] #values are dictionaries with years as keys and numbers as columns
        values = [x.values() for x in stats.values()] 
        return words, years, values #warning: unicode!


def write_to_file(something, filename):
        with open(filename, 'w') as f:
                    json.dump(something, f)
	f.close() 


main()
