"""
Chart data from CSVs
"""
import argparse
import os
import math
import decimal
import csv
from collections import defaultdict
import matplotlib
import matplotlib.pyplot as plt
import seaborn as sns
import pandas as pd
import numpy
from matplotlib.ticker import FuncFormatter
import json

from py_utils import *

# ACM won't accept "T3" fonts, force avoiding them
print("Setting matplot configurations")
matplotlib.rcParams['pdf.fonttype'] = 42
matplotlib.rcParams['ps.fonttype'] = 42

def get_color_palette():
    # Use a diverging color palette for the two versions of the naive baseline
    # and the Diospyros kernels, then another color for Nature. Reverse the
    # diverging palette for that the faster naive baseline is darker.
    base_palette = sns.color_palette("RdBu", 6)
    nature_color = sns.color_palette("RdYlBu", 3)[1]

    colorblind = sns.color_palette("colorblind", 6)

    palette = [
                base_palette[4], # light blue   - Naive
                base_palette[5], # dark blue    - Naive (fixed size)
                colorblind[2],   # green        - Diospyros
                colorblind[4],   # light purple - Nature
                colorblind[5],   # gold         - Eigen
                ]
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
    """
    Returns a pretty formatted name for the benchmark using the input array
    sizes.
    """
    if benchmark == conv2d:
        return "{}×{}\n{}×{}\n2DConv".format(row["I_ROWS"],
                                            row["I_COLS"],
                                            row["F_ROWS"],
                                            row["F_COLS"])
    if benchmark == matmul:
        return "{}×{}\n{}×{}\nMatMul".format(row["A_ROWS"],
                                       row["A_COLS"],
                                       row["B_ROWS"],
                                       row["B_COLS"])
    if benchmark == qrdecomp:
        return "{}×{}\nQR\nDecomp".format(row["SIZE"], row["SIZE"])

    if benchmark == qprod:
        return "4, 3, 4, 3\nQProd"

    print("Error: need size formatting for benchmark", benchmark)

# Handle new size formatting, which inserts newlines for chart spacing
def split_size(size_str):
    def is_size(s):
        return "×" in s or "," in s
    str_rows = size_str.split("\n")
    size = ", ".join([s for s in str_rows if is_size(s)])
    name = "".join([s for s in str_rows if not is_size(s)])
    return size, name

# Turn a size string into a single int for comparison within a benchmark
def size_as_int(size_str):
    def array_to_size(a):
        if "×" in a:
            return numpy.prod([int(v) for v in a.split("×")])
        return int(a)

    s, _ = split_size(size_str)
    sizes = [array_to_size(a) for a in s.split(",")]

    # Power of 10 hack to combine multiple sizes into one int
    combined_size = 0
    for i, size in enumerate(reversed(sizes)):
        combined_size += size * pow(10, i * 2)
    return combined_size


def get_baseline_names(benchmark):
    baselines = ["Naive", "Naive hard size", "Nature"]
    return baselines

def get_kernel_name_formatted(kernel):
    if kernel == "Naive hard size":
        return "Naive (fixed size)"
    return kernel

all_kernels = [
    'Naive',
    'Naive (fixed size)',
    'Diospyros',
    'Nature',
    'Eigen',
    'Expert',
]

def chart(graph_data):

    name = "all_benchmarks_chart.pdf"
    print("Charting graph for all benchmarks:", name)

    # Don't show expert in the chart, since there is only 1
    graph_data = graph_data[graph_data.Kernel != "Expert"]

    figsize=(15,3)
    # Normalize data against key
    norm_key = 'Naive (fixed size)'
    # Location of the color of the norm value
    norm_color_loc = all_kernels.index(norm_key)

    # Select the rows from the dataframe that will be used to normalize
    norm_table = graph_data[graph_data['Kernel'] == norm_key][['Benchmark', 'Size', 'Cycles (simulation)']]
    graph_data_with_norm = graph_data.merge(
        norm_table,
        how='left',
        on=['Benchmark', 'Size'],
        suffixes=['', '-naive']
    )
    graph_data_with_norm['cycles-norm'] = graph_data_with_norm['Cycles (simulation)-naive'] / graph_data_with_norm['Cycles (simulation)']

    # This sets the gray background, among other things
    sns.set(font_scale=1.04)

    graph_data_with_norm['size_sort'] = graph_data_with_norm.Size.map(size_as_int)

    # Sort based on the kernel first, then on the order specified
    graph_data_with_norm = graph_data_with_norm.sort_values(
            ['Benchmark', 'Order', 'size_sort'])

    plt.rcParams['figure.figsize'] = figsize
    colors = get_color_palette()
    ax = sns.barplot(
        x="Size",
        y="cycles-norm",
        hue="Kernel",
        palette=colors,
        data=graph_data_with_norm)
    locs, labels = plt.xticks()

    ax.set(ylabel="Speedup over Naive (fixed-size)")

    # Add a line at 1 to show speed up baseline
    ax.axhline(y=1, linewidth=1, color=colors[norm_color_loc])
    ax.set_yscale('log')

    formatterY = FuncFormatter(lambda y, pos: '{0:g}'.format(y))
    ax.yaxis.set_major_formatter(formatterY)
    plt.yticks([0.25, 0.5, 1, 2, 4, 8, 16, 32])

    legend = ax.legend(loc='center left', bbox_to_anchor=(1, 0.5), ncol=1)
    for t in legend.texts:
        if t.get_text() == "Naive (fixed size)":
            t.set_text("Naive\n(fixed size)")

    ax.set_xlabel('')
    plt.savefig(name, bbox_inches='tight')
    plt.close()

def chart_small(graph_data):
    """Small summary chart for the extended abstract"""
    name = "extended_abstract_chart.pdf"
    print("Charting small graph for extended abstract:", name)
    small_benchmarks = [
        ("4×4\n4×4\nMatMul", "MatMul\n4×4 4×4"),
        ("4×4\n3×3\n2DConv", "2DConv\n4×4 3×3"),
        ("3×3\nQR\nDecomp", "QRDecomp\n3×3"),
        ("4, 3, 4, 3\nQProd", "QProd\n4, 3, 4, 3"),
    ]

    pd.set_option("mode.chained_assignment", None)

    # Combine Nature and Eigen into a single "Library" type
    graph_data = graph_data[((graph_data.Kernel != 'Nature') & (graph_data.Kernel != 'Eigen')) | \
                            (((graph_data.Benchmark == 'q-prod') | (graph_data.Benchmark == 'qr-decomp')) & (graph_data.Kernel == 'Eigen')) | \
                            (((graph_data.Benchmark != 'q-prod') & (graph_data.Benchmark != 'qr-decomp')) & (graph_data.Kernel == 'Nature'))]
    graph_data.loc[graph_data.Kernel == 'Nature', 'Kernel'] = 'Library'
    graph_data.loc[graph_data.Kernel == 'Eigen', 'Kernel'] = 'Library'

    # Only show a few kernels
    graph_data = graph_data[graph_data.Kernel.isin(["Naive (fixed size)", "Library", "Diospyros"])]

    # and only a few benchmarks
    graph_data = graph_data[graph_data.Size.isin(list(map(lambda b: b[0], small_benchmarks)))]

    # reorder
    graph_data.loc[graph_data.Kernel == 'Library', 'Order'] = 2
    graph_data.loc[graph_data.Kernel == 'Diospyros', 'Order'] = 3

    # rename
    for old, new in small_benchmarks:
        graph_data.loc[graph_data.Size == old, 'Size'] = new
    graph_data.loc[graph_data.Kernel == 'Naive (fixed size)', 'Kernel'] = 'Loop nest'

    figsize=(6,2.6)
    # Normalize data against key
    norm_key = 'Loop nest'
    # Location of the color of the norm value
    norm_color_loc = all_kernels.index('Naive (fixed size)')

    # Select the rows from the dataframe that will be used to normalize
    norm_table = graph_data[graph_data['Kernel'] == norm_key][['Benchmark', 'Size', 'Cycles (simulation)']]
    graph_data_with_norm = graph_data.merge(
        norm_table,
        how='left',
        on=['Benchmark', 'Size'],
        suffixes=['', '-naive']
    )
    graph_data_with_norm['cycles-norm'] = graph_data_with_norm['Cycles (simulation)-naive'] / graph_data_with_norm['Cycles (simulation)']

    # This sets the gray background, among other things
    sns.set(font_scale=1.04)

    # Sort based on the kernel first, then on the order specified
    graph_data_with_norm = graph_data_with_norm.sort_values(
            ['Order', 'Kernel', 'Benchmark'])

    plt.rcParams['figure.figsize'] = figsize
    colors = get_color_palette()
    ax = sns.barplot(
        y="Size",
        x="cycles-norm",
        hue="Kernel",
        palette=colors,
        data=graph_data_with_norm)

    ax.set(xlabel="Speedup over naive (fixed-size) loop nest")

    # Add a line at 1 to show speed up baseline
    ax.axvline(x=1, linewidth=1, color=colors[norm_color_loc])
    ax.set_xscale('log')

    formatterX = FuncFormatter(lambda x, pos: '{0:g}'.format(x))
    ax.xaxis.set_major_formatter(formatterX)
    plt.xticks([1.e-01, 0.5, 1, 5, 10, 15, 20, 25])

    ax.legend(loc='upper center', bbox_to_anchor=(0.5, 1.2), ncol=3)

    ax.set_ylabel('')
    plt.savefig(name, bbox_inches='tight')
    plt.close()

def format_data(files):
    chart_data = defaultdict(list)
    benchmark_data = pd.DataFrame(
        columns=['Benchmark', 'Kernel', 'Size', 'Cycles (simulation)',
                 'Time', 'Memory'])

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
                    x["kernel"] = "Diospyros"
                baseline_names.add(x["kernel"])

            for i, kernel in enumerate(baseline_names):
                kernel_row = next(x for x in data if x["kernel"] == kernel)
                benchmark_data = benchmark_data.append({
                    'Benchmark': benchmark,
                    'Kernel': get_kernel_name_formatted(kernel),
                    'Size': size,
                    'Cycles (simulation)': int(kernel_row["cycles"]),
                    'Order' : all_kernels.index(get_kernel_name_formatted(kernel)),
                    'Time': kernel_row['time'],
                    'Memory': kernel_row['memory'],
                    'saturated': kernel_row['saturated']},
                    ignore_index=True)

    return benchmark_data

def read_csvs(dir, benchmarks, out):
    """Read in CSVs for cycle-level data and compilation statistics"""
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

                # Load synthesis statistics.
                stats_file = os.path.join(params_config, 'stats.json')
                with open(stats_file) as f:
                    stats_data = json.load(f)

                for file in listdir(params_config):
                    # Load performance data.
                    pre, ext = os.path.splitext(file)
                    if ext != ".csv":
                        continue

                    with open(file,  newline='') as csvfile:
                        reader = csv.DictReader(csvfile)
                        if not writer:
                            fields = reader.fieldnames
                            fields = ["benchmark"] + fields \
                                + ["time", "memory", "saturated"]
                            writer = csv.DictWriter(outfile, fieldnames=fields)
                            writer.writeheader()

                        for row in reader:
                            row["benchmark"] = benchmark
                            row.update(stats_data)
                            writer.writerow(row)
                            rows += 1
    print("Combined {} individual runs into one CSV: {}".format(rows, out))
    return files

def main():
    # Argument parsing
    parser = argparse.ArgumentParser()
    parser.add_argument('-d', '--directory', type=str,
        help="Directory from which to read CSVs")
    parser.add_argument('-o', '--output', type=str, default="all_benchmarks.csv",
        help="Non-default output file")
    args = parser.parse_args()

    input_dir = args.directory

    files = read_csvs(input_dir, benchmarks, args.output)
    df = format_data(files)

    # Write data out
    df.to_csv(args.output, index=False)

    chart(df)
    chart_small(df)

if __name__ == main():
    main()
