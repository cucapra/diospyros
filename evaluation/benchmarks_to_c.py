"""Compile several configurations of each benchmark (creating DSL programs via
synthesis queries, then compiling the results to C).
"""
from datetime import datetime
from threading import Timer
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

def call_synth_with_timeout(benchmark, params_f, p_dir, timeout):
    # Call example-gen, AKA synthesis. This is long running, so include an
    # for a timeout (which will usually still write early found solutions)
    gen = sp.Popen([
        "./dios-example-gen",
        "-b", benchmark,
        "-p", params_f,
        "-o", p_dir
        ])

    def kill(process):
        print("Hit timeout, killing synthesis subprocess")
        process.kill()

    timer = Timer(timeout, kill, [gen])
    try:
        print("Running synthesis for {}, timeout: {}".format(benchmark, timeout))
        timer.start()
        gen.communicate()
    finally:
        timer.cancel()

def synthesize_benchmark(dir, benchmark, timeout):
    b_dir = os.path.join(dir, benchmark)
    make_dir(b_dir)

    # Get list of parameter configurations for this benchmark
    params_list = parameters[benchmark]

    for params in params_list:
        p_dir = os.path.join(b_dir, params_to_name(benchmark, params))
        make_dir(p_dir)
        params_f = os.path.join(p_dir, "params.json")
        with open(params_f, 'w+') as f:
            json.dump(params, f, indent=4)

        call_synth_with_timeout(benchmark, params_f, p_dir, timeout)

def compile_benchmark(dir, benchmark):
    b_dir = os.path.join(dir, benchmark)
    for params_config in listdir(b_dir):
        if not os.path.isdir(params_config):
            continue
        for file in listdir(params_config):
            pre, ext = os.path.splitext(file)
            if ext != ".rkt":
                continue

            c_file = pre + ".c"
            if os.path.exists(c_file):
                print("Skipping already-build C file: {}".format(c_file))
                continue

            print("Compiing to file {}".format(file))
            sp.call(["./dios", "-o", c_file, file])

def make_dir(d):
    """Makes a directory if it does not already exist"""
    if not os.path.exists(d):
        os.mkdir(d)

def listdir(d):
    """Lists the full paths of the contents of a directory"""
    return [os.path.join(d, f) for f in os.listdir(d)]

def main():
    # Argument parsing
    parser = argparse.ArgumentParser()
    parser.add_argument('-b', '--build', action='store_true',
        help="Build ./dios and ./dios-example-gen executables")
    parser.add_argument('-t', '--timeout', type=int, default=60,
        help="Timeout per call to ./dios-example-gen (seconds)")
    parser.add_argument('-o', '--output', type=str, default="",
        help="Non-default output directory")
    parser.add_argument('--skipsynth', action='store_true',
        help="Skip the synthesis step and just build to C")
    parser.add_argument('--skipc', action='store_true',
        help="Skip building to C and just run synthesis")
    args = parser.parse_args()

    if args.skipsynth and args.skipc:
        print("Skipping both synthesis and building to C, doing nothing")
        exit(1)

    # Make clean and build if requested
    if args.build:
        sp.call(["make", "clean"])
        sp.call(["make", "build"])

    # Create a subdirectory for this run
    make_dir(results_dir)

    if args.output:
        cur_results_dir = args.output
        print("Writing results to: {}".format(args.output))
    if not args.output:
        rev = sp.check_output(["git", "rev-parse", "--short", "HEAD"])
        rev = rev.decode("utf-8").strip()
        date = datetime.now().strftime('%Y-%m-%d_%H-%M')
        cur_results_dir = os.path.join(results_dir, '{}_{}'.format(date, rev))
        make_dir(cur_results_dir)
        print("Writing results to: {}".format(cur_results_dir))

    if not args.skipsynth:
        synthesize_benchmark(cur_results_dir, conv2d, args.timeout)

    if not args.skipc:
        compile_benchmark(cur_results_dir, conv2d)

if __name__ == main():
    main()
