#!/usr/bin/env python3

import json
import sys

# requires a full design space

try:
    f = sys.argv[1]
except:
    print("Expects report json file: ./pretty_print.py <report>.json")
    exit(-1)

handle = open(f, "r")
x = json.load(handle)
handle.close()

for i in range(1, 9):
    for j in range(1, 9):
        for k in range(1, 9):
            try:
                data = x[str(i)][str(j)][str(k)]
                unoptimized = float(data["unoptimized"])
                optimized = float(data["optimized"])
                eigen = float(data["baseline"])
                speedup = unoptimized / optimized
                espeedup = eigen / optimized
#                print("{}\t {}\t {}\t {}\t {} \t {} \t {} \t {} \t {}".format(i, j, k, data["Test Failure"], speedup, espeedup, eigen, unoptimized, optimized))
                print("{}\t {}\t {}\t {}\t {} \t {}".format(i, j, k, data["Test Failure"], speedup, espeedup))
            except:
                pass

# Only uncomment this if the entire 8x8x8 run is completed and you want to see the heatmap
"""
import numpy as np
import matplotlib
import matplotlib.pyplot as plt
# sphinx_gallery_thumbnail_number = 2

input_cols = ["1", "2", "3", "4", "5", "6", "7", "8"]
output_cols = ["1", "2", "3", "4", "5", "6", "7", "8"]

results = np.zeros((8, 8))

for i in range(1, 9):
    for j in range(1, 9):
        data = x["1"][str(i)][str(j)]
        results[i-1, j-1] = float(data["unoptimized"]) / float(data["optimized"])
results = np.around(results, 2)

fig, axs = plt.subplots(8)
ax = axs[0]
im = ax.imshow(results)

# We want to show all ticks...
ax.set_xticks(np.arange(len(output_cols)))
ax.set_yticks(np.arange(len(input_cols)))
# ... and label them with the respective list entries
ax.set_xticklabels(output_cols)
ax.set_yticklabels(input_cols)

# Rotate the tick labels and set their alignment.
plt.setp(ax.get_xticklabels(), rotation=45, ha="right",
         rotation_mode="anchor")

# Loop over data dimensions and create text annotations.
for i in range(len(input_cols)):
    for j in range(len(output_cols)):
        text = ax.text(j, i, results[i, j],
                       ha="center", va="center", color="w")

ax.set_title("Speed up results")
fig.tight_layout()
plt.show()
"""
