import subprocess
from collections import OrderedDict
import csv
import glob
import sys

OPTIONS = ["baseline", "slp", "opt"]


def main():
    # iterate over benchmark folder files, that end with .c
    # for each of the files
    #   run each of {baseline, slp, opt}
    #   gather data and write them into dictionary
    #   write into a CSV with file name as the first item
    bench_directory = sys.argv[1]
    csv_path = sys.argv[2]

    print(f"{bench_directory} is the target benchmark directory.")
    matching_bench_files = glob.glob(f"{bench_directory}*.c")
    data_dict = OrderedDict()

    for bench_name in matching_bench_files:
        stripped_bench_name = bench_name.replace('..', '')[1:]
        print(f"{stripped_bench_name} is being run.")
        results = []

        for option in OPTIONS:
            option_name = "run-" + option
            subprocess.run(
                ["make", "-C", "../..", f"{option_name}", f"test=./{stripped_bench_name}"])
            with open("../../data.txt", "r") as fp:
                file_contents = fp.read()
                data = float(file_contents.strip())
                results.append(data)
            print("Deleting data.txt.")
            subprocess.run(["rm", "../../data.txt"])

        print(results)
        further_stripped_name = stripped_bench_name[stripped_bench_name.rindex(
            "/") + 1:stripped_bench_name.rindex(".c")]
        data_dict[further_stripped_name] = results

    print(f"Writing to {csv_path}.")
    with open(csv_path, "w+") as csvfile:
        csvwriter = csv.writer(csvfile)
        # write first row
        csvwriter.writerow(["Benchmark", "Baseline", "SLP", "Diospyros"])
        for bench_name, bench_results in data_dict.items():
            csvwriter.writerow([bench_name] + bench_results)
    print("Finished data collection.")


main()
