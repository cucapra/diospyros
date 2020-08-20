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
matplotlib.rcParams['text.usetex'] = True

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
                colorblind[2],   # green        - Bronzite
                colorblind[4],   # light purple - Nature
                colorblind[5],   # gold         - Eigen
                ]

    # if benchmark == matmul:
    #     # For matmul, use purple for the expert
    #     palette.append(sns.color_palette("colorblind", 5)[4])

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

def get_baseline_names(benchmark):
    baselines = ["Naive", "Naive hard size", "Nature"]
    # if benchmark == matmul:
    #     return baselines + ["Expert"]
    return baselines

def get_kernel_name_formatted(kernel):
    if kernel == "Naive hard size":
        return "Naive (fixed size)"
    return kernel

all_kernels = [
    'Naive',
    'Naive (fixed size)',
    'Bronzite',
    'Nature',
    'Eigen',
    'Expert',
]

def chart(graph_data):

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

    # Sort based on the kernel first, then on the order specified
    graph_data_with_norm = graph_data_with_norm.sort_values(
            ['Order', 'Kernel', 'Benchmark'])

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
    plt.yticks([1.e-01, 0.5, 1, 2, 3, 5, 8, 13, 21])

    for t in ax.legend().texts:
        if t == "Naive (fixed size)":
            t.set_text("Naive\n(fixed size)")

    ax.legend(loc='center left', bbox_to_anchor=(1, 0.5), ncol=1)

    # Annotate each bar with its value
    # for p in ax.patches:
        # if math.isnan(p.get_height()) or p.get_height() > 100:
            # continue
        # ax.annotate("%d" % p.get_height(), (p.get_x() + p.get_width() / 2., p.get_height()),
             # ha='center', va='center', fontsize=11, color='black', xytext=(0, 6),
             # textcoords='offset points')

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


def format_data(files):
    chart_data = defaultdict(list)
    benchmark_data = pd.DataFrame(
        columns=['Benchmark', 'Kernel', 'Size', 'Cycles (simulation)'])

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
                    'Order' : all_kernels.index(get_kernel_name_formatted(kernel))},
                    ignore_index=True)

    return benchmark_data
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

                # Load synthesis statistics.
                stats_file = os.path.join(params_config, 'stats.json')
                if os.path.exists(stats_file):
                    with open(stats_file) as f:
                        stats_data = json.load(f)
                else:
                    # Tolerate missing statistics (because we added them
                    # recently).
                    stats_data = {
                        'time': 0,
                        'memory': 0,
                    }

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
                                + ["time", "memory"]
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
    parser.add_argument('-o', '--output', type=str, default="combined",
        help="Non-default output directory")
    args = parser.parse_args()

    input_dir = os.path.join(results_dir, args.directory)

    files = read_csvs(input_dir, benchmarks, args.output)
    df = format_data(files)

    # Write data out
    df.to_csv('combined.csv', index=False)

    chart(df)

if __name__ == main():
    main()
