"""
Compile and run several configurations of each benchmark: creating DSL
programs via synthesis queries, compiling the results to C, and running. Each
step can be skipped if needed (the last one will only work on a server with
Xtensa tools installed.)
"""
from datetime import datetime
from threading import Timer
import argparse
import json
import os
import subprocess as sp

from py_utils import *

parameters = {
    conv2d : [
        # {
        #     "input-rows": 2,
        #     "input-cols": 2,
        #     "filter-rows": 2,
        #     "filter-cols": 2,
        #     "reg-size": 4
        # },
        # {
        #     "input-rows": 3,
        #     "input-cols": 3,
        #     "filter-rows": 2,
        #     "filter-cols": 2,
        #     "reg-size": 4
        # },
        # {
        #     "input-rows": 4,
        #     "input-cols": 4,
        #     "filter-rows": 2,
        #     "filter-cols": 2,
        #     "reg-size": 4
        # },
        # {
        #     "input-rows": 5,
        #     "input-cols": 5,
        #     "filter-rows": 2,
        #     "filter-cols": 2,
        #     "reg-size": 4
        # },
        # {
        #     "input-rows": 6,
        #     "input-cols": 6,
        #     "filter-rows": 2,
        #     "filter-cols": 2,
        #     "reg-size": 4
        # },
        # {
        #     "input-rows": 7,
        #     "input-cols": 7,
        #     "filter-rows": 2,
        #     "filter-cols": 2,
        #     "reg-size": 4
        # },
        # {
        #     "input-rows": 8,
        #     "input-cols": 8,
        #     "filter-rows": 2,
        #     "filter-cols": 2,
        #     "reg-size": 4
        # },
        {
            "input-rows": 3,
            "input-cols": 3,
            "filter-rows": 3,
            "filter-cols": 3,
            "reg-size": 4
        },
        # {
        #     "input-rows": 4,
        #     "input-cols": 4,
        #     "filter-rows": 3,
        #     "filter-cols": 3,
        #     "reg-size": 4
        # },
        {
            "input-rows": 5,
            "input-cols": 5,
            "filter-rows": 3,
            "filter-cols": 3,
            "reg-size": 4
        },
        # {
        #     "input-rows": 6,
        #     "input-cols": 6,
        #     "filter-rows": 3,
        #     "filter-cols": 3,
        #     "reg-size": 4
        # },
        # {
        #     "input-rows": 7,
        #     "input-cols": 7,
        #     "filter-rows": 3,
        #     "filter-cols": 3,
        #     "reg-size": 4
        # },
        # {
        #     "input-rows": 8,
        #     "input-cols": 8,
        #     "filter-rows": 3,
        #     "filter-cols": 3,
        #     "reg-size": 4
        # },
        # {
        #     "input-rows": 9,
        #     "input-cols": 9,
        #     "filter-rows": 3,
        #     "filter-cols": 3,
        #     "reg-size": 4
        # },
        # {
        #     "input-rows": 16,
        #     "input-cols": 16,
        #     "filter-rows": 3,
        #     "filter-cols": 3,
        #     "reg-size": 4
        # },
        # {
        #     "input-rows": 128,
        #     "input-cols": 128,
        #     "filter-rows": 8,
        #     "filter-cols": 8,
        #     "reg-size": 4
        # },
    ],
    matmul : [
        # {
        #     "A-rows": 2,
        #     "A-cols": 2,
        #     "B-rows": 2,
        #     "B-cols": 2,
        #     "reg-size": 4
        # },
        {
            "A-rows": 2,
            "A-cols": 3,
            "B-rows": 3,
            "B-cols": 3,
            "reg-size": 4
        },
        {
            "A-rows": 3,
            "A-cols": 3,
            "B-rows": 3,
            "B-cols": 3,
            "reg-size": 4
        },
        # {
        #     "A-rows": 4,
        #     "A-cols": 4,
        #     "B-rows": 4,
        #     "B-cols": 4,
        #     "reg-size": 4
        # },
        # {
        #     "A-rows": 5,
        #     "A-cols": 5,
        #     "B-rows": 5,
        #     "B-cols": 5,
        #     "reg-size": 4
        # },
        # {
        #     "A-rows": 6,
        #     "A-cols": 6,
        #     "B-rows": 6,
        #     "B-cols": 6,
        #     "reg-size": 4
        # },
        # {
        #     "A-rows": 7,
        #     "A-cols": 7,
        #     "B-rows": 7,
        #     "B-cols": 7,
        #     "reg-size": 4
        # },
        # {
        #     "A-rows": 8,
        #     "A-cols": 8,
        #     "B-rows": 8,
        #     "B-cols": 8,
        #     "reg-size": 4
        # },
        # {
        #     "A-rows": 16,
        #     "A-cols": 16,
        #     "B-rows": 16,
        #     "B-cols": 16,
        #     "reg-size": 4
        # },
    ],
    # dft : [
    #     # {
    #     #     "N" : 8,
    #     #     "reg-size": 4
    #     # }
    # ]
    qrdecomp : [
        {
            "N": 3,
            "reg-size": 4
        },
        {
            "N": 4,
            "reg-size": 4
        }
    ],
    qprod : [
        {
            "reg-size": 4
        },
    ],
}

def params_to_name(benchmark, params):
    if benchmark == conv2d:
        return '{}x{}_{}x{}_{}r'.format(params["input-rows"],
                                            params["input-cols"],
                                            params["filter-rows"],
                                            params["filter-cols"],
                                            params["reg-size"])
    if benchmark == matmul:
        return '{}x{}_{}x{}_{}r'.format(params["A-rows"],
                                            params["A-cols"],
                                            params["B-rows"],
                                            params["B-cols"],
                                            params["reg-size"])
    if benchmark == dft:
        return '{}_{}r'.format(params["N"],
                               params["reg-size"])

    print("Warning: haven't defined nice filename for: ", benchmark)
    return str(params)

def call_synth_with_timeout(benchmark, params_f, p_dir, timeout):
    # Call example-gen, AKA synthesis. This is long running, so include an
    # for a timeout (which will usually still write early found solutions)
    # TODO clean this up
    gen = sp.Popen([
        "make",
        "-B",
        "{}-egg".format(benchmark),
        "SPLIT=100"])

    def kill(process):
        print("Hit timeout, killing synthesis subprocess")
        process.kill()

    timer = Timer(timeout, kill, [gen])
    try:
        print("Running synthesis for {}, timeout: {}".format(benchmark, timeout))
        sp.call([
            "cp",
            params_f,
            "{}-params".format(benchmark)])
        sp.call([
            "cat",
            params_f,])
        timer.start()
        gen.communicate()

        # TODO clean this up
        sp.call([
            "mv",
            "{}-out/kernel.c".format(benchmark),
            "{}/egg-kernel.c".format(p_dir)])

        imports = """#include <float.h>
                     #include <math.h>
                     #include <stdint.h>
                     #include <stdio.h>
                     #include <stdlib.h>
                     #include <xtensa/sim.h>
                     #include <xtensa/tie/xt_pdxn.h>
                     #include <xtensa/tie/xt_timer.h>
                     #include <xtensa/xt_profiling.h>

                     """

        if benchmark == dft:
            imports += """#define PI 3.1415926535897932384626433832795
                          xb_vecMxf32 cos_MXF32(xb_vecMxf32 v);
                          xb_vecMxf32 sin_MXF32(xb_vecMxf32 v);"""

        with open("{}/egg-kernel.c".format(p_dir), 'r+') as f:
            content = f.read()
            f.seek(0, 0)
            f.write(imports + '\n' + content)
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

def dimmensions_for_benchmark(benchmark, params):
    if benchmark == conv2d:
        return [
                "I_ROWS=" + str(params["input-rows"]),
                "I_COLS=" + str(params["input-cols"]),
                "F_ROWS=" + str(params["filter-rows"]),
                "F_COLS=" + str(params["filter-cols"]),
            ]
    if benchmark == matmul:
        return [
                "A_ROWS=" + str(params["A-rows"]),
                "A_COLS=" + str(params["A-cols"]),
                "B_ROWS=" + str(params["B-rows"]),
                "B_COLS=" + str(params["B-cols"]),
            ]
    if benchmark == dft:
        return [
                "N=" + str(params["N"]),
            ]
    if benchmark == qrdecomp:
        return [
                "N=" + str(params["N"]),
            ]
    if benchmark == qprod:
        return []
    print("Error: haven't dimensions  for: ", benchmark)
    exit(1)

def run_benchmark(dir, benchmark, build, force):
    b_dir = os.path.join(dir, benchmark)
    for params_config in listdir(b_dir):
        if not os.path.isdir(params_config):
            continue
        params_json = os.path.join(params_config, "params.json")
        with open(params_json, 'r') as f:
            params = json.load(f)
            print(params)
        for file in listdir(params_config):
            pre, ext = os.path.splitext(file)
            if ext != ".c":
                continue

            csv_file = pre + ".csv"
            if not force and os.path.exists(csv_file):
                print("Skipping already-run CSV file: {}".format(csv_file))
                continue

            print("Running, outputting to file {}".format(csv_file))

            harness = os.path.join(harness_dir, benchmark)
            if build:
                sp.call(["make", "-C", harness, "clean"])

            set_dimms = dimmensions_for_benchmark(benchmark, params)
            print(set_dimms)
            set_kernel = "KERNEL_SRC=" + os.path.abspath(file)
            set_output = "OUTFILE=" + os.path.abspath(csv_file)
            sp.call(["make", "-C", harness, "run", set_kernel, set_output] + set_dimms)

def main():
    # Argument parsing
    parser = argparse.ArgumentParser()
    parser.add_argument('-b', '--build', action='store_true',
        help="Build ./dios and ./dios-example-gen executables")
    parser.add_argument('-f', '--force', action='store_true',
        help="Force overwrite old results")
    parser.add_argument('-t', '--timeout', type=int, default=100,
        help="Timeout per call to ./dios-example-gen (seconds)")
    parser.add_argument('-o', '--output', type=str, default="",
        help="Non-default output directory")
    parser.add_argument('--skipsynth', action='store_true',
        help="Skip the synthesis step and just build to C")
    parser.add_argument('--skipc', action='store_true',
        help="Skip building to C and just run synthesis")
    parser.add_argument('--skiprun', action='store_true',
        help="Skip running generated C code")
    args = parser.parse_args()

    if args.skipsynth and args.skipc and args.skiprun:
        print("Skipping synthesis, building to C, and running: doing nothing")
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
        for b in benchmarks:
            synthesize_benchmark(cur_results_dir, b, args.timeout)
    # if not args.skipc:
    #     for b in benchmarks:
    #         compile_benchmark(cur_results_dir, b, args.force)
    if not args.skiprun:
        for b in benchmarks:
            run_benchmark(cur_results_dir, b, args.build, args.force)

if __name__ == main():
    main()
