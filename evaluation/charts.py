"""
Chart data from CSVs
"""
import argparse
import json
import os
import subprocess as sp
import csv
from collections import defaultdict
import matplotlib.pyplot as plt
import seaborn as sns
import pandas as pd
import numpy as np

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

def chart(name, graph_data, figsize):
    graph_data = graph_data.sort_values(['Kernel']).reset_index(drop=True).sort_values(["Cycles (simulation)"], ascending=False).reset_index(drop=True)
    plt.rcParams['figure.figsize'] = figsize
    ax = sns.barplot(x="Size", y="Cycles (simulation)", hue="Kernel", data=graph_data)
    locs, labels = plt.xticks()
    for p in ax.patches:
        ax.annotate("%d" % p.get_height(), (p.get_x() + p.get_width() / 2., p.get_height()),
             ha='center', va='center', fontsize=11, color='gray', xytext=(0, 6),
             textcoords='offset points')
    ax.set_ylim(0, 1900)
    ax.set_xlabel('')
    plt.legend(bbox_to_anchor=(1.05, 1), loc=2, borderaxespad=0.)
    plt.savefig(name, bbox_inches='tight')
    plt.close()

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

    print("Error: need size formatting for benchmark")

def get_kernel_name_formatted(kernel):
    if kernel == "Naive hard size":
        return "Naive (fixed)"
    return kernel

def chart_csv(file):
    chart_data = defaultdict(list)
    with open(file,  newline='') as csvfile:
        reader = csv.DictReader(csvfile)
        for row in reader:
            chart_data[row["benchmark"]].append(row)

    for benchmark, rows in chart_data.items():
        benchmark_data = pd.DataFrame(columns=['Kernel', 'Size', 'Cycles (simulation)'])
        data_per_size = defaultdict(list)
        for row in rows:
            size = get_size_formatted(benchmark, row)
            data_per_size[size].append(row)
        for size, data in data_per_size.items():
            for kernel in ["Naive", "Naive hard size", "Nature"]:
                kernel_row = next(x for x in data if x["kernel"] == kernel)
                benchmark_data = benchmark_data.append({
                    'Kernel': get_kernel_name_formatted(kernel),
                    'Size': size,
                    'Cycles (simulation)': int(kernel_row["cycles"])},
                    ignore_index=True)

            rosette_data = [x for x in data if x["kernel"] == "Rosette"]
            highest_cost = max(rosette_data, key=lambda r: int(r["cost"]))
            benchmark_data = benchmark_data.append({
                'Kernel': "Diospyros (first)",
                'Size': size,
                'Cycles (simulation)': int(highest_cost["cycles"])},
                ignore_index=True)

            fastest = min(rosette_data, key=lambda r: int(r["cycles"]))
            benchmark_data = benchmark_data.append({
                'Kernel': "Diospyros (fastest)",
                'Size': size,
                'Cycles (simulation)': int(fastest["cycles"])},
                ignore_index=True)

        chart(benchmark + ".pdf", benchmark_data, figsize=(12,3))

def main():
    # Argument parsing
    parser = argparse.ArgumentParser()
    parser.add_argument('-d', '--directory', type=str,
        help="Directory from which to read CSVs")
    parser.add_argument('-o', '--output', type=str, default="combined.csv",
        help="Non-default output directory")
    args = parser.parse_args()

    read_csvs(os.path.join(results_dir, args.directory), conv2d, args.output)
    chart_csv(args.output)

if __name__ == main():
    main()