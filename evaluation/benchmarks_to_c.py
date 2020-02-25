"""Run several configurations of each benchmark (creating DSL programs,
compiling them to C).
"""

from datetime import datetime
import argparse
import json
import os
import subprocess as sp

results_dir = "../diospyros-private/results/"

conv2d = "2d-conv"
matmul = "mat-mul"

benchmarks = [matmul, conv2d]

parameters = {
    conv2d : [
        {
            "input-rows": 2,
            "input-cols": 2,
            "filter-rows": 2,
            "filter-cols": 2,
            "iterations": 10,
            "reg-size": 4
        },
        {
            "input-rows": 3,
            "input-cols": 3,
            "filter-rows": 2,
            "filter-cols": 2,
            "iterations": 30,
            "reg-size": 4
        },
    ]
}

def params_to_name(benchmark, params):
    if benchmark == conv2d:
        return '{}x{}_{}x{}_{}i_{}r'.format(params["input-rows"],
                                            params["input-cols"],
                                            params["filter-rows"],
                                            params["filter-cols"],
                                            params["iterations"],
                                            params["reg-size"])

    print("Warning: haven't defined nice filename for: ", benchmark)
    return str(params)

def run_benchmark(dir, benchmark):
    b_dir = os.path.join(dir, benchmark)
    make_dir(b_dir)

    # Get list of parameter configurations for this benchmark
    params_list = parameters[benchmark]

    for params in params_list:
        p_dir = params_to_name(benchmark, params)
        make_dir(p_dir)
        params_f = os.path.join(p_dir, "params.json")
        with open(params_f, 'w+') as f:
            json.dump(params, f)

        sp.call([
            "./dios-example-gen",
            "-b", benchmark,
            "-p", params_f,
            "-o", p_dir
            ])

def make_dir(d):
    if not os.path.exists(d):
        os.mkdir(d)

def main():
    # Argument parsing
    parser = argparse.ArgumentParser()
    parser.add_argument('-b', '--build', action='store_true',
        help="Build ./dios and ./dios-example-gen executables")
    args = parser.parse_args()

    # Make clean and build if requested
    if args.build:
        sp.call(["make", "clean"])
        sp.call(["make", "build"])

    # Create a subdirectory for this run
    make_dir(results_dir)

    rev = sp.check_output(["git", "rev-parse", "--short", "HEAD"])
    rev = rev.decode("utf-8").strip()
    date = datetime.now().strftime('%Y-%m-%d_%H-%M')
    cur_results_dir = os.path.join(results_dir, '{}_{}'.format(date, rev))
    make_dir(cur_results_dir)

    run_benchmark(cur_results_dir, conv2d)

    pass

if __name__ == main():
    main()