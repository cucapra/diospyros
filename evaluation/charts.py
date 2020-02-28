"""
Chart data from CSVs
"""
import argparse
import json
import os
import subprocess as sp
import csv

from py_utils import *

def read_csvs(dir, benchmark, out):
    b_dir = os.path.join(dir, benchmark)

    rows = 0
    with open(out, 'w', newline='') as outfile:
        writer = None
        for params_config in listdir(b_dir):
            if not os.path.isdir(params_config):
                continue
            for file in listdir(params_config):
                pre, ext = os.path.splitext(file)
                if ext != ".csv":
                    continue

                with open(file,  newline='') as csvfile:
                    reader = csv.DictReader(csvfile)
                    if not writer:
                            writer = csv.DictWriter(outfile,
                                fieldnames=reader.fieldnames)
                            writer.writeheader()

                    for row in reader:
                        writer.writerow(row)
                        rows += 1
    print("Combined {} individual runs into one CSV: {}".format(rows, out))

def main():
    # Argument parsing
    parser = argparse.ArgumentParser()
    parser.add_argument('-d', '--directory', type=str,
        help="Directory from which to read CSVs")
    parser.add_argument('-o', '--output', type=str, default="combined.csv",
        help="Non-default output directory")
    args = parser.parse_args()

    read_csvs(os.path.join(results_dir, args.directory), conv2d, args.output)

if __name__ == main():
    main()