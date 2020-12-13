import json
import sys
import re


def fmt_int(n):
    return '{:,}'.format(n)


def fmt_x(n):
    return '{:.1f}$\\times$'.format(n)


def dpm_results():
    # Load cycle counts.
    results_txt = sys.stdin.read()
    matches = re.findall(
        r'DecomposeProjectionMatrix - (\w+): (\d+) cycles', results_txt
    )
    cycles = {m: int(c) for m, c in matches}

    # Output values.
    out = {'{}-cycles'.format(m.lower()): fmt_int(c)
           for m, c in cycles.items()}
    out['speedup'] = fmt_x(cycles['Eigen'] / cycles['Dios'])

    print(json.dumps(out, sort_keys=True, indent=2))


if __name__ == '__main__':
    dpm_results()
