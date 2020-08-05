"""
Chart data from CSVs
"""
import argparse
import json
import os
import decimal
import subprocess as sp
import csv
from collections import defaultdict
import matplotlib
import matplotlib.pyplot as plt
import seaborn as sns
import pandas as pd
import numpy as np

from py_utils import *

# ACM won't accept "T3" fonts, force avoiding them
print("Setting matplot configurations")
matplotlib.rcParams['pdf.fonttype'] = 42
matplotlib.rcParams['ps.fonttype'] = 42
# matplotlib.rcParams['text.usetex'] = True

def get_color_palette(benchmark):
    # Use a diverging color palette for the two versions of the naive baseline
    # and the Diospyros kernels, then another color for Nature. Reverse the
    # diverging palette for that the faster naive baseline is darker.
    base_palette = sns.color_palette("RdBu", 6)
    nature_color = sns.color_palette("RdYlBu", 3)[1]
    palette = [base_palette[1], base_palette[0], nature_color] + base_palette[4:]

    if benchmark == matmul:
        # For matmul, use purple for the expert
        palette.append(sns.color_palette("colorblind", 5)[4])

    return palette

def get_y_limit(benchmark):
    if benchmark == conv2d:
        return 3500
    if benchmark == matmul:
        return 325
    if benchmark == matadd:
        return 325

    print("Error: need y limit for benchmark", benchmark)

def get_size_formatted(benchmark, row):
    if benchmark == conv2d:
        return "{}×{} Input, {}×{} Filter".format(row["I_ROWS"],
                                                  row["I_COLS"],
                                                  row["F_ROWS"],
                                                  row["F_COLS"])
    if benchmark == matmul:
        return "{}×{} by {}×{}".format(row["A_ROWS"],
                                       row["A_COLS"],
                                       row["B_ROWS"],
                                       row["B_COLS"])
    if benchmark == matadd:
        return "{}×{} by {}×{}".format(row["A_ROWS"],
                                       row["A_COLS"],
                                       row["B_ROWS"],
                                       row["B_COLS"])

    print("Error: need size formatting for benchmark", benchmark)

def get_baseline_names(benchmark):
    baselines = ["Naive", "Naive hard size", "Nature"]
    if benchmark == matmul:
        return baselines + ["Expert"]
    if benchmark == matadd:
        return ["Naive", "Naive hard size"]
    return baselines

def get_kernel_name_formatted(kernel):
    if kernel == "Naive hard size":
        return "Naive (fixed size)"
    return kernel

def chart(benchmark, graph_data, figsize):
    # This sets the gray background, among other things
    sns.set(font_scale=1.07)

    # Sort based on the kernel first, then on the order specified
    graph_data = graph_data.sort_values(['Kernel']).reset_index(drop=True).sort_values(["Order"], ascending=True).reset_index(drop=True)

    plt.rcParams['figure.figsize'] = figsize
    colors = get_color_palette(benchmark)
    ax = sns.barplot(x="Size", y="Cycles (simulation)", hue="Kernel", palette=colors, data=graph_data)
    locs, labels = plt.xticks()

    # Annotate each bar with its value
    for p in ax.patches:
        ax.annotate("%d" % p.get_height(), (p.get_x() + p.get_width() / 2., p.get_height()),
             ha='center', va='center', fontsize=11, color='black', xytext=(0, 6),
             textcoords='offset points')

    ax.set_ylim(0, get_y_limit(benchmark))
    ax.set_xlabel('')
    plt.savefig(benchmark + ".pdf", bbox_inches='tight')
    plt.close()

def write_summary_statistics(benchmark, benchmark_data, file):
    benchmark_data.sort_values(["Order"])
    # Indexed by size:
    naive_cycles = {}
    nature_cycles = {}

    headers = [
        "Kernel",
        "Size",
        "Cycles",
        "Speedup vs. Naive",
        "Speedup vs. Nature",
    ]

    def format_fl(fl):
        with decimal.localcontext() as ctx:
            d = decimal.Decimal(fl)
            ctx.rounding = decimal.ROUND_DOWN
            floored = round(d, 1)
            return "{0:.1f}".format(floored)

    # Get speedup baselines
    for _, row in benchmark_data.iterrows():
        if row["Kernel"] == "Naive":
            naive_cycles[row["Size"]] = float(row["Cycles (simulation)"])
        if row["Kernel"] == "Nature":
            nature_cycles[row["Size"]] = float(row["Cycles (simulation)"])

    speedups_naive = []
    speedups_nature = []

    with open(file, 'w', newline='') as f:
        writer = csv.DictWriter(f, fieldnames=headers)
        writer.writeheader()

        for _, r in benchmark_data.iterrows():
            size = r["Size"]
            cycles = r["Cycles (simulation)"]

            speedup_naive = naive_cycles[size]/cycles
            speedup_nature = nature_cycles[size]/cycles

            if "Diospyros (fastest)" in r["Kernel"]:
                speedups_naive.append(speedup_naive)
                speedups_nature.append(speedup_nature)

                writer.writerow({
                    "Kernel" : r["Kernel"],
                    "Size" : size,
                    "Cycles" : r["Cycles (simulation)"],
                    "Speedup vs. Naive" : format_fl(speedup_naive),
                    "Speedup vs. Nature" : format_fl(speedup_nature),
                })

        writer.writerow({
            "Kernel" : "Min Diospyros speedup over X",
            "Size" : "","Cycles" : "",
            "Speedup vs. Naive" : format_fl(min(speedups_naive)),
            "Speedup vs. Nature" : format_fl(min(speedups_nature)),
        })
        writer.writerow({
            "Kernel" : "Max Diospyros speedup over X",
            "Size" : "","Cycles" : "",
            "Speedup vs. Naive" : format_fl(max(speedups_naive)),
            "Speedup vs. Nature" : format_fl(max(speedups_nature)),
        })


def format_and_chart_data(full_file, summary_file):
    chart_data = defaultdict(list)
    with open(full_file,  newline='') as csvfile:
        reader = csv.DictReader(csvfile)
        for row in reader:
            chart_data[row["benchmark"]].append(row)

    # Iterate for each benchmark
    for benchmark, rows in chart_data.items():
        benchmark_data = pd.DataFrame(columns=['Kernel', 'Size', 'Cycles (simulation)'])

        # Gather data by kernel size first
        data_per_size = defaultdict(list)
        for row in rows:
            size = get_size_formatted(benchmark, row)
            data_per_size[size].append(row)

        # For each size, go through the baselines first, then find the first
        # (lowest cost from the cost model) and fastest (lowest actual cycles)
        # from Diospyros
        for size, data in sorted(data_per_size.items(), reverse=True):
            for i, kernel in enumerate(get_baseline_names(benchmark)):
                kernel_row = next(x for x in data if x["kernel"] == kernel)
                benchmark_data = benchmark_data.append({
                    'Kernel': get_kernel_name_formatted(kernel),
                    'Size': size,
                    'Cycles (simulation)': int(kernel_row["cycles"]),
                    'Order' : i if i < 3 else 5},
                    ignore_index=True)

            rosette_data = [x for x in data if x["kernel"] == "Diospyros"]
            highest_cost = max(rosette_data, key=lambda r: int(r["cost"]))
            benchmark_data = benchmark_data.append({
                'Kernel': "Diospyros (first)",
                'Size': size,
                'Cycles (simulation)': int(highest_cost["cycles"]),
                'Order' : 3},
                ignore_index=True)

            fastest = min(rosette_data, key=lambda r: int(r["cycles"]))
            benchmark_data = benchmark_data.append({
                'Kernel': "Diospyros (fastest)",
                'Size': size,
                'Cycles (simulation)': int(fastest["cycles"]),
                'Order' : 4},
                ignore_index=True)

        chart(benchmark, benchmark_data, figsize=(8,3))
        # write_summary_statistics(benchmark, benchmark_data, summary_file)

def read_csvs(dir, benchmarks, out):
    rows = 0
    files = []
    for benchmark in benchmarks:
        b_dir = os.path.join(dir, benchmark)
        base = out + "-" + benchmark
        file = base + ".csv"
        files.append((file, base + "-summary.csv"))

        # Combine each runs' CSV file into one
        with open(file, 'w', newline='') as outfile:
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
                            fields = reader.fieldnames
                            fields = ["benchmark", "cost"] + fields
                            writer = csv.DictWriter(outfile, fieldnames=fields)
                            writer.writeheader()

                        for row in reader:
                            row["benchmark"] = benchmark
                            row["cost"] = os.path.basename(pre).replace("sol-", "")
                            writer.writerow(row)
                            rows += 1
    print("Combined {} individual runs into one CSV: {}".format(rows, out))
    return files

def main():
    # Argument parsing
    parser = argparse.ArgumentParser()
    parser.add_argument('-d', '--directory', type=str,
        help="Directory from which to read CSVs")
    parser.add_argument('-o', '--output', type=str, default="combined",
        help="Non-default output directory")
    args = parser.parse_args()

    input_dir = os.path.join(results_dir, args.directory)

    files = read_csvs(input_dir, benchmarks, args.output)
    for file, summary in files:
        format_and_chart_data(file, summary)

if __name__ == main():
    main()
