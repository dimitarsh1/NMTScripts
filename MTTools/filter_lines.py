import argparse
import os
from itertools import izip

def filter_files(fileOne, fileTwo, cutoff, prefix):
    dirOne = os.path.dirname(os.path.realpath(fileOne))
    of1 = open(os.path.join(dirOne, prefix, '.in'), 'w')
    dirTwo = os.path.dirname(os.path.realpath(fileTwo))
    of2 = open(os.path.join(dirTwo, prefix, '.ref'), 'w')
    with open(fileOne, "r") as f1, open(fileTwo, "r") as f2:
        for index, (line1, line2) in enumerate(izip(f1, f2)):
            if len(line1.split()) < cutoff and len(line2.split()) < cutoff:
                of1.write(line1)
                of2.write(line2)
    of1.close()
    of2.close()

def main():
    parser = argparse.ArgumentParser(description='Filtering a file (and a reference) from long sentences.')
    parser.add_argument('-i', '--input', required=True, help='the path to the input file.')
    parser.add_argument('-r', '--reference', required=True, help='the path to the reference file')
    parser.add_argument('-p', '--refix', required=True, help='the prefix for saving the files')
    parser.add_argument('-c', '--cutoff', required=True, help='the cutoff - how many characters max we keep')

    args = parser.parse_args()
    filter_files(args.input, args.reference, args.cutoff, args.prefix)

if __name__ == "__main__":
    main()
