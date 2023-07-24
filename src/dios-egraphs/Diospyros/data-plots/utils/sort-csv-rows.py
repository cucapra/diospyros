import subprocess
from collections import OrderedDict
import csv
import glob
import sys


def main():
    # iterate over benchmark folder files, that end with .c
    # for each of the files
    #   run each of {baseline, slp, opt}
    #   gather data and write them into dictionary
    #   write into a CSV with file name as the first item
    csv_path = sys.argv[1]

    data = []
    header = None
    with open(csv_path, "r") as csvfile:
        csvreader = csv.reader(csvfile)
        # read first row
        for i, row in enumerate(csvreader):
            if i == 0:
                header = row
                continue
            data.append(row)
    assert header != None
    data = sorted(data, key=lambda tup: tup[0])
    with open(csv_path, "w+") as csvfile:
        csvwriter = csv.writer(csvfile)
        csvwriter.writerow(header)
        for row in data:
            csvwriter.writerow(row)


main()
