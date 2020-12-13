"""This script generates a table like Table 1 from the ASPLOS paper. It
lists the benchmarks and their optimization characteristics: i.e., the
time and memory required for Diospyros's execution.

It reads results from `combined.csv`, which is produced by `charts.py`,
as well as the fixed list of benchmarks in `benchmarks.csv`.

The only CLI flag is `--plain`. Use `python3 benchtbl.py --plain` to get
a readable plain-text table; omit `--plain` to get a fragment of TeX
code for a table like in the paper.
"""
import csv
import sys
from functools import reduce


def print_row(seq, end=True):
    print(' & '.join(seq) + (r' \\' if end else ' &'))


def wrap_cmd(cmd, s):
    return '\\{}{{{}}}'.format(cmd, s)


# Header row.
COLS = [
    'Benchmark',
    'Description',
    'Ref.\\ LOC',
    'Size',
    'Time',
    'Memory',
]


# Handle new size formatting, which inserts newlines for chart spacing
def split_size(size_str):
    def is_size(s):
        return "×" in s or "," in s
    str_rows = size_str.split("\n")
    size = ", ".join([s for s in str_rows if is_size(s)])
    name = "".join([s for s in str_rows if not is_size(s)])
    return size, name


# Turn a size string into a single int for comparison within a benchmark
def compare_size(size_str):
    def array_to_size(a):
        if "×" in a:
            return reduce(lambda a, b: a * b,
                          [int(v) for v in a.split("×")])
        return int(a)

    s, _ = split_size(size_str)
    sizes = [array_to_size(a) for a in s.split(",")]

    # Power of 10 hack to combine multiple sizes into one int
    combined_size = 0
    for i, size in enumerate(reversed(sizes)):
        combined_size += size * pow(10, i * 2)
    return combined_size


def benchtbl(plain=False):
    """Dump a table. Make a LaTeX table by default. Otherwise, produce
    plain text suitable for viewing in a terminal.
    """
    # Descriptions of the benchmarks.
    with open('benchmarks.csv') as f:
        reader = csv.DictReader(f)
        benchmarks = list(reader)

    # Sort the benchmarks by name.
    benchmarks.sort(key=lambda r: r['bench'])

    # Data for each *size* of each benchmark.
    benchdata = {r['bench']: [] for r in benchmarks}
    with open('combined.csv') as f:
        reader = csv.DictReader(f)
        for row in reader:
            if row['Kernel'] == 'Bronzite':
                size, bench = split_size(row['Size'])
                bench = bench.replace("\n", "")

                # Format times.
                if 'Time' in row:
                    stime = float(row['Time'])
                    if stime > 60 * 60:
                        stime_txt = '{:.0f}h {:.0f}m'.format(
                            stime / (60 * 60),
                            (stime % (60 * 60)) / 60,
                        )
                    elif stime > 60:
                        stime_txt = '{:.0f}m {:.0f}s'.format(
                            stime / 60,
                            stime % 60,
                        )
                    elif stime > 60:
                        stime_txt = '{:.0f}s'.format(stime)
                    else:
                        stime_txt = '{:.1f}s'.format(stime)

                    if row['Saturated?'] != "Yes":
                        stime_txt += '*' if plain else "\\rlap{$^\dagger$}"
                else:
                    stime_txt = ''

                # Format bytes.
                if 'Memory' in row:
                    smem = int(row['Memory'])
                    if smem > 10**9:
                        smem_txt = '{:.1f}~GB'.format(smem / 10**9)
                    else:
                        smem_txt = '{:,}~MB'.format(int(smem / 10**6))
                else:
                    smem_txt = ''

                benchdata[bench].append({
                    'size': size,
                    'cycles': row['Cycles (simulation)'],
                    'time': stime_txt,
                    'memory': smem_txt,
                })
        for v in benchdata.values():
            v.sort(key=lambda v: compare_size(v['size']))


    if plain:
        rowfmt = '{:<10} {:<10} {:<15} {:<10} {:<10}'
        cols = [c.replace('\\', '') for c in COLS if c != 'Description']
        print(rowfmt.format(*cols))
        print(rowfmt.format(*('=' * len(c) for c in cols)))
    else:
        print(r'\begin{tabular}{llrcrrc}')
        print(r'\toprule')
        print_row(wrap_cmd('textbf', s) for s in COLS)
        print(r'\midrule')

    for j, row in enumerate(benchmarks):
        sizes = benchdata[row['bench']]

        if not plain:
            # Separation between benchmarks.
            if j != 0:
                print(r'\addlinespace[.7em]')

            multirow = r'multirow[t]{{{}}}{{*}}'.format(len(sizes) or 1)
            print_row([wrap_cmd(multirow, s) for s in [
                wrap_cmd('bench', row['bench']),
                row['desc'],
                row['ref-loc'],
            ]], end=False)

        if not sizes:
            print('no results for {}'.format(row['bench']), file=sys.stderr)
            print(r'\\')
            continue

        for i, size in enumerate(sizes):
            if plain:
                print(rowfmt.format(
                    row['bench'] if i == 0 else '',
                    row['ref-loc'] if i == 0 else '',
                    size['size'],
                    size['time'],
                    size['memory'].replace('~', ' '),
                ))
            else:
                if i != 0:
                    # On non-first sizes, pad out the left columns.
                    print('&' * 3, end=' ')
                print_row([
                    size['size'],
                    size['time'],
                    size['memory'],
                ])

    if plain:
        print('* Equality saturation timed out after 180s.')
    else:
        print(r'\bottomrule')
        print(r'\end{tabular}')
        print(r'\\$\dagger$ Equality saturation timed out after 180s.')


if __name__ == '__main__':
    benchtbl('--plain' in sys.argv[1:])
