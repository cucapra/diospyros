import subprocess
from collections import OrderedDict
import csv
import glob
import sys

OPTIONS = ["baseline", "slp", "opt"]


def main():
    bench_directory = sys.argv[1]
    csv_path = sys.argv[2]

    print(f"{bench_directory} is the target benchmark directory to merge. Will ignore 'all-data.csv'.")
    matching_bench_files = glob.glob(f"{bench_directory}/*.csv")

    with open(csv_path, "w+") as csv_wfile:
        csvwriter = csv.writer(csv_wfile)
        csvwriter.writerow(
            ["Group", "Benchmark", "Baseline", "SLP", "Diospyros"])
        for bench_name in matching_bench_files:
            stripped_bench_name = bench_name[bench_name.rindex(
                "/") + 1:bench_name.rindex(".csv")]
            if stripped_bench_name != "all-data":
                print(f"Handling {stripped_bench_name}.")
                with open(bench_name, "r+") as csv_rfile:
                    csvreader = csv.reader(csv_rfile)

                    for i, row in enumerate(csvreader):
                        if i == 0:
                            continue
                        csvwriter.writerow([stripped_bench_name] + row)


main()
