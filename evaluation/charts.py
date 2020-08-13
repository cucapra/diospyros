"""
Chart data from CSVs
"""
import argparse
import json
import os
import math
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
matplotlib.rcParams['text.usetex'] = True

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
        return 4500
    if benchmark == matmul:
        return 800

    if benchmark == qrdecomp:
        return 70000

    if benchmark == qprod:
        return 2000

    print("Error: need y limit for benchmark", benchmark)

def get_size_formatted(benchmark, row):
    if benchmark == conv2d:
        return "{}×{}, {}×{}\n2DConv".format(row["I_ROWS"],
                                            row["I_COLS"],
                                            row["F_ROWS"],
                                            row["F_COLS"])
    if benchmark == matmul:
        return "{}×{}, {}×{}\nMatMul".format(row["A_ROWS"],
                                       row["A_COLS"],
                                       row["B_ROWS"],
                                       row["B_COLS"])
    if benchmark == qrdecomp:
        return "{}×{}\nQRDecomp".format(row["N"], row["N"])

    if benchmark == qprod:
        return "4, 3, 4, 3\nQProd"

    print("Error: need size formatting for benchmark", benchmark)

def get_baseline_names(benchmark):
    baselines = ["Naive", "Naive hard size", "Nature"]
    # if benchmark == matmul:
    #     return baselines + ["Expert"]
    return baselines

def get_kernel_name_formatted(kernel):
    if kernel == "Naive hard size":
        return "Naive (fixed size)"
    return kernel

def chart(graph_data, figsize):
    # This sets the gray background, among other things
    sns.set(font_scale=1.07)

    graph_data.to_csv('combined.csv', index = False, header=True)

    # Sort based on the kernel first, then on the order specified
    graph_data = graph_data.sort_values(['Kernel', 'Benchmark', 'Order'])

    print(graph_data)

    plt.rcParams['figure.figsize'] = figsize
    colors = get_color_palette(matmul)
    ax = sns.barplot(x="Size", y="Cycles (simulation)", hue="Kernel", palette=colors, data=graph_data)
    locs, labels = plt.xticks()

    ax.legend(loc=1)

    # Annotate each bar with its value
    for p in ax.patches:
        if math.isnan(p.get_height()) or p.get_height() > 100:
            continue
        ax.annotate("%d" % p.get_height(), (p.get_x() + p.get_width() / 2., p.get_height()),
             ha='center', va='center', fontsize=11, color='black', xytext=(0, 6),
             textcoords='offset points')

    ax.set_ylim(0, 1800)
    ax.set_xlabel('')
    plt.savefig("all" + ".pdf", bbox_inches='tight')
    plt.close()

def write_summary_statistics(benchmark_data):
    file = "summary.csv"
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

            if "Diospyros" in r["Kernel"]:
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


def format_and_chart_data(files):
    chart_data = defaultdict(list)
    benchmark_data = pd.DataFrame(columns=['Benchmark', 'Kernel', 'Size', 'Cycles (simulation)'])

    for file, summary in files:
        with open(file,  newline='') as csvfile:
            reader = csv.DictReader(csvfile)
            for row in reader:
                chart_data[row["benchmark"]].append(row)

    # Iterate for each benchmark
    for benchmark, rows in chart_data.items():

        # Gather data by kernel size first
        data_per_size = defaultdict(list)
        for row in rows:
            size = get_size_formatted(benchmark, row)
            data_per_size[size].append(row)


        # For each size, go through the baselines first, then find the first
        # (lowest cost from the cost model) and fastest (lowest actual cycles)
        # from Diospyros
        for size, data in sorted(data_per_size.items(), reverse=True):
            baseline_names = set()
            for x in data:
                if x["kernel"] == "Diospyros":
                    x["kernel"] = "Bronzite"
                baseline_names.add(x["kernel"])

            for i, kernel in enumerate(baseline_names):
                kernel_row = next(x for x in data if x["kernel"] == kernel)
                benchmark_data = benchmark_data.append({
                    'Benchmark': benchmark,
                    'Kernel': get_kernel_name_formatted(kernel),
                    'Size': size,
                    'Cycles (simulation)': int(kernel_row["cycles"]),
                    'Order' : i if i < 3 else 5},
                    ignore_index=True)

    chart(benchmark_data, figsize=(12,3))
    # write_summary_statistics(benchmark_data)

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
                            fields = ["benchmark"] + fields
                            writer = csv.DictWriter(outfile, fieldnames=fields)
                            writer.writeheader()

                        for row in reader:
                            row["benchmark"] = benchmark
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
    format_and_chart_data(files)

if __name__ == main():
    main()