"""
Ablation study for turning off vectorization, takes 2 full run directories
"""
import argparse
import os
import math
import csv
from collections import defaultdict
import operator
import json

from py_utils import *

def read_csvs(vec, no_vec, benchmarks, out):
    """Read in CSVs for cycle-level data and compilation statistics"""

    def to_dict(name):
        data = defaultdict(dict)
        for benchmark in benchmarks:
            dir = os.path.join(name, benchmark)
            base = out + "-" + benchmark
            file = base + ".csv"

            # Combine each run's CSV file into cycle-only data
            with open(file, 'w', newline='') as outfile:
                for params_config in listdir(dir):
                    if not os.path.isdir(params_config):
                        continue
                    with open(os.path.join(params_config, "egg-kernel.csv"),  newline='') as csvf:
                        for row in csv.DictReader(csvf):
                            data[params_config.replace(name, "")][row["kernel"]] = row["cycles"]
        return data

    speedups = {}

    vec_data = to_dict(vec)
    no_vec_data = to_dict(no_vec)

    for name, kernel_dict in vec_data.items():
        for kernel, vec_cycles in kernel_dict.items():
            no_vec_cycles = no_vec_data[name][kernel]

            if kernel == "Diospyros":
                speedup = int(no_vec_cycles)/float(vec_cycles)
                print("{},{},{},{}".format(name, vec_cycles, no_vec_cycles, speedup))
                speedups[name] = speedup
            else:
                if vec_cycles != no_vec_cycles:
                    print("DIFFERENT BASELINE: {},{},{},{}".format(name, vec_cycles, no_vec_cycles, kernel))

    sorted_speedups = sorted(speedups.items(), key=operator.itemgetter(1))
    faster = ["{},{}".format(name, speedup) for name, speedup in sorted_speedups if speedup > 1.0]
    slower = ["{},1/S = {}".format(name, 1/speedup) for name, speedup in sorted_speedups if speedup < 1.0]
    same = ["{},{}".format(name, speedup) for name, speedup in sorted_speedups if speedup == 1.0]
    print("Faster: {}\n{}\nSlower: {}\n{}\nSame: {}\n{}".format(
        len(faster), "\n".join(faster),
        len(slower), "\n".join(slower),
        len(same),  "\n".join(same)))

def main():
    # Argument parsing
    parser = argparse.ArgumentParser()
    parser.add_argument('-d', '--directory', type=str,
        help="Directory from which to read CSVs for standard run")
    parser.add_argument('-n', '--novec', type=str,
        help="Directory from which to read CSVs for no vec run")
    parser.add_argument('-o', '--output', type=str, default="all_benchmarks.csv",
        help="Non-default output file")
    args = parser.parse_args()

    input_dir = args.directory

    files = read_csvs( args.directory, args.novec, benchmarks, args.output)

if __name__ == main():
    main()
