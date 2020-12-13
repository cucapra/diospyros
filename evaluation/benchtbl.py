import csv
import sys
import numpy


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
            return numpy.prod([int(v) for v in a.split("×")])
        return int(a)

    s, _ = split_size(size_str)
    sizes = [array_to_size(a) for a in s.split(",")]

    # Power of 10 hack to combine multiple sizes into one int
    combined_size = 0
    for i, size in enumerate(reversed(sizes)):
        combined_size += size * pow(10, i * 2)
    return combined_size

def benchtbl():
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
                        stime_txt += "\\rlap{$^\dagger$}"
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


    print(r'\begin{tabular}{llrcrrc}')
    print(r'\toprule')
    print_row(wrap_cmd('textbf', s) for s in COLS)
    print(r'\midrule')
    for j, row in enumerate(benchmarks):
        # Separation between benchmarks.
        if j != 0:
            print(r'\addlinespace[.7em]')

        sizes = benchdata[row['bench']]
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
            if i != 0:
                # On non-first sizes, pad out the left columns.
                print('&' * 3, end=' ')
            print_row([
                size['size'],
                size['time'],
                size['memory'],
            ])
    print(r'\bottomrule')
    print(r'\end{tabular}')
    print(r'\\$\dagger$ Equality saturation timed out after 180s.')


if __name__ == '__main__':
    benchtbl()
