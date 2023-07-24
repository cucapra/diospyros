import matplotlib.pyplot as plt
from matplotlib import colors as mcolors
import numpy as np
import csv
import sys


def plot():
    csv_file_path = sys.argv[1]
    out_name = sys.argv[2]

    names = []
    baseline = []
    slp = []
    diospyros = []

    with open(csv_file_path) as csvfile:
        csvreader = csv.reader(csvfile)

        for i, row in enumerate(csvreader):
            assert len(row) == 4
            if i == 0:
                continue

            name = row[0]
            name = name.replace(r'-by-', '×')
            name = name.replace('-', ' ')
            names.append(name)
            baseline.append(1.0)
            slp.append(float(row[1]) / float(row[2]))
            diospyros.append(float(row[1]) / float(row[3]))

    # data to plot
    n_groups = len(names)

    # create plot
    fig, ax = plt.subplots()
    index = np.arange(n_groups)
    bar_width = 0.25
    opacity = 0.8

    rects1 = plt.bar(index, baseline, bar_width,
                     alpha=opacity,
                     color='xkcd:baby blue',
                     label='Baseline')

    rects2 = plt.bar(index + bar_width, slp, bar_width,
                     alpha=opacity,
                     color='xkcd:deep sky blue',
                     label='SLP')

    rects2 = plt.bar(index + 2 * bar_width, diospyros, bar_width,
                     alpha=opacity,
                     color='xkcd:vibrant blue',
                     label='Diospyros')

    plt.xlabel('Benchmark')
    plt.ylabel('Speedup')
    plt.title('Speedup from Baseline for SLP and Diospyros Vectorization')
    plt.xticks(index + 1.1 * bar_width, names)
    plt.xticks(rotation=30, ha='right')
    plt.legend()

    plt.tight_layout()

    plt.savefig(f"{out_name}.png")


plot()
