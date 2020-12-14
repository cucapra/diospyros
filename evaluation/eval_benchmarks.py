"""
Compile and run several configurations of each benchmark: (1) creating DSL
programs via equality saturation queries and compiling the results to C,
and (2) running the benchmark in simulation on the Xtensa compiler. Each step
can be skipped if needed (the last one will only work on a server with Xtensa
tools installed.)
"""
from datetime import datetime
from threading import Timer, Thread
import argparse
import json
import os
import psutil
import subprocess as sp
import time

from py_utils import *

PARAMETERS = {
    conv2d : [
        {
            "input-rows": 3,
            "input-cols": 3,
            "filter-rows": 2,
            "filter-cols": 2,
            "reg-size": 4
        },
        {
            "input-rows": 3,
            "input-cols": 5,
            "filter-rows": 3,
            "filter-cols": 3,
            "reg-size": 4
        },
        {
            "input-rows": 10,
            "input-cols": 10,
            "filter-rows": 2,
            "filter-cols": 2,
            "reg-size": 4
        },
        {
            "input-rows": 16,
            "input-cols": 16,
            "filter-rows": 2,
            "filter-cols": 2,
            "reg-size": 4
        },
        {
            "input-rows": 3,
            "input-cols": 3,
            "filter-rows": 3,
            "filter-cols": 3,
            "reg-size": 4
        },
        {
            "input-rows": 4,
            "input-cols": 4,
            "filter-rows": 3,
            "filter-cols": 3,
            "reg-size": 4
        },
        {
            "input-rows": 8,
            "input-cols": 8,
            "filter-rows": 3,
            "filter-cols": 3,
            "reg-size": 4
        },
        {
            "input-rows": 10,
            "input-cols": 10,
            "filter-rows": 3,
            "filter-cols": 3,
            "reg-size": 4
        },
        {
            "input-rows": 16,
            "input-cols": 16,
            "filter-rows": 3,
            "filter-cols": 3,
            "reg-size": 4
        },
        {
            "input-rows": 10,
            "input-cols": 10,
            "filter-rows": 4,
            "filter-cols": 4,
            "reg-size": 4
        },
        {
            "input-rows": 16,
            "input-cols": 16,
            "filter-rows": 4,
            "filter-cols": 4,
            "reg-size": 4
        },
    ],
    matmul : [
        {
            "A-rows": 2,
            "A-cols": 2,
            "B-rows": 2,
            "B-cols": 2,
            "reg-size": 4
        },
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
        {
            "A-rows": 4,
            "A-cols": 4,
            "B-rows": 4,
            "B-cols": 4,
            "reg-size": 4
        },
        {
            "A-rows": 8,
            "A-cols": 8,
            "B-rows": 8,
            "B-cols": 8,
            "reg-size": 4
        },
        {
            "A-rows": 10,
            "A-cols": 10,
            "B-rows": 10,
            "B-cols": 10,
            "reg-size": 4
        },
        {
            "A-rows": 16,
            "A-cols": 16,
            "B-rows": 16,
            "B-cols": 16,
            "reg-size": 4
        },
    ],
    qprod : [
        {
            "reg-size": 4
        },
    ],
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
}

class MemChecker(Thread):
    """A thread that continuously checks the memory usage of a process
    in the background to report the maximum measurement.
    """
    def __init__(self, pid, delay=0.2):
        """Check the process `pid` every `delay` seconds.
        """
        super(MemChecker, self).__init__()
        self.pid = pid
        self.maxmem = 0
        self.delay = delay
        self._stop_please = False

    def run(self):
        while not self._stop_please:
            try:
                proc = psutil.Process(self.pid)

                # Get memory information for this process (which is probably
                # make) and all its subprocesses (which include the actual
                # synthesis engine).
                meminfo = [proc.memory_info()] \
                    + [child.memory_info()
                       for child in proc.children(recursive=True)]

                # Resident Set Size is the amount of data actually in
                # RAM. It is given in bytes.
                total_rss = sum(m.rss for m in meminfo)
                self.maxmem = max(self.maxmem, total_rss)

            except psutil.NoSuchProcess:
                pass

            except psutil.ProcessLookupError:
                pass

            time.sleep(self.delay)

    def stop(self):
        self._stop_please = True


def params_to_name(benchmark, params):
    """Formatting for CSV data"""
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

    if benchmark == qrdecomp:
        return '{}_{}r'.format(params["N"],
                               params["reg-size"])

    if benchmark == qprod:
        return '{}r'.format(params["reg-size"])

    print("Error: haven't defined nice filename for: ", benchmark)
    exit(1)

def call_synth_with_timeout(benchmark, params_f, p_dir, eq_sat_timeout, validation):
    # Call example-gen, AKA symbolic execution and equality saturation.
    sp.check_call([
        "rm",
        "-rf",
        "{}-out/".format(benchmark)])
    sp.check_call([
        "mkdir",
        "{}-out/".format(benchmark)])
    sp.check_call([
        "cp",
        params_f,
        "{}-params".format(benchmark)])
    sp.check_call([
        "cat",
        params_f,])

    synth_cmd = [
        "make",
        "-B",
        "{}-egg".format(benchmark),
    ]

    # Run translation validation if requested
    if validation:
        synth_cmd += ["BACKEND_FLAGS=--validation"]

    # Start wall clock time
    start_time = time.time()
    gen = sp.Popen(synth_cmd, env=dict(os.environ, TIMEOUT=str(eq_sat_timeout)))

    # Start a thread to measure the memory usage.
    memthread = MemChecker(gen.pid)
    memthread.start()

    try:
        print("Running synthesis for {}, equality saturation timeout: {}".format(benchmark, eq_sat_timeout))

        gen.communicate()
        end_time = time.time()

        elapsed_time = end_time - start_time

        sp.check_call([
            "mv",
            "{}-out/kernel.c".format(benchmark),
            "{}/egg-kernel.c".format(p_dir)])

        sp.check_call([
            "mv",
            "{}-out/spec.rkt".format(benchmark),
            "{}/spec.rkt".format(p_dir)])

        sp.check_call([
            "mv",
            "{}-out/prelude.rkt".format(benchmark),
            "{}/prelude.rkt".format(p_dir)])

        sp.check_call([
            "mv",
            "{}-out/outputs.rkt".format(benchmark),
            "{}/outputs.rkt".format(p_dir)])

        sp.check_call([
            "mv",
            "{}-out/res.rkt".format(benchmark),
            "{}/res.rkt".format(p_dir)])


        print("Synthesis and compilation finished in {:.1f} seconds using {:.1f} MB".format(
            elapsed_time,
            memthread.maxmem / 10**6,
        ))
        return {
            'time': elapsed_time,
            'memory': memthread.maxmem,
        }

    finally:
        memthread.stop()

def synthesize_benchmark(dir, benchmark, eq_sat_timeout, parameters, validation):
    """Call synthesis and write out data"""
    b_dir = os.path.join(dir, benchmark)
    make_dir(b_dir)

    # Get list of parameter configurations for this benchmark
    params_list = parameters[benchmark]

    for params in params_list:
        name = params_to_name(benchmark, params)
        p_dir = os.path.join(b_dir, name)
        make_dir(p_dir)
        params_f = os.path.join(p_dir, "params.json")
        with open(params_f, 'w+') as f:
            json.dump(params, f, indent=4)

        stats = call_synth_with_timeout(benchmark, params_f, p_dir, eq_sat_timeout, validation)

        # Write synthesis statistics to a little JSON file here.
        stats_csv = os.path.join(p_dir, "stats.json")
        with open(stats_csv, 'w') as f:
            json.dump(stats, f, indent=4, sort_keys=True)

def only_validation(dir, benchmark):
    """Call synthesis and write out data"""
    b_dir = os.path.join(dir, benchmark)
    for params_config in listdir(b_dir):
        if not os.path.isdir(params_config):
            continue
        sp.check_call([
            "./dios",
            "--validation",
            "-e",
            "-o", "{}/egg-kernel.c".format(params_config),
            "{}".format(params_config)])

def dimmensions_for_benchmark(benchmark, params):
    """Make file parameters per benchmark"""
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
    if benchmark == qrdecomp:
        return [
                "SIZE=" + str(params["N"]),
            ]
    if benchmark == qprod:
        return None
    print("Error: missing dimensions for: ", benchmark)
    exit(1)

def run_benchmark(dir, benchmark, build, force):
    """Run benchmark in simulation on the Xtensa compiler, writing timing files
    out to a CSV"""
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
            sp.check_call(["make", "-C", harness, "clean"])

            set_dimms = dimmensions_for_benchmark(benchmark, params)
            print(set_dimms)
            set_kernel = "KERNEL_SRC=" + os.path.abspath(file)
            set_output = "OUTFILE=" + os.path.abspath(csv_file)
            make_run = ["make", "-C", harness, "run", set_kernel, set_output]
            if set_dimms:
                make_run += set_dimms
            sp.check_call(make_run)

def main():
    # Argument parsing
    parser = argparse.ArgumentParser()
    parser.add_argument('-b', '--build', action='store_true',
        help="Build ./dios and ./dios-example-gen executables")
    parser.add_argument('-f', '--force', action='store_true',
        help="Force overwrite old results")
    parser.add_argument('-t', '--timeout', type=int, default=180,
        help="Timeout per call to the equality saturation engine (seconds)")
    parser.add_argument('-o', '--output', type=str, default="",
        help="Non-default output directory")
    parser.add_argument('--skipsynth', action='store_true',
        help="Skip the synthesis step and run existing generated code")
    parser.add_argument('--skiprun', action='store_true',
        help="Skip running generated C code")
    parser.add_argument('--skiplargemem', action='store_true',
        help="Skip kernels with large memory consumption")
    parser.add_argument('--test', action='store_true',
        help="Run just the smallest size per benchmark as a test")
    parser.add_argument('-v', '--validation', action='store_true',
        help="Run translation validation")
    args = parser.parse_args()

    if args.skipsynth and args.skiprun and not args.validation:
        print("Skipping synthesis, validation, and running: doing nothing")
        exit(1)

    # Make clean and build if requested
    if args.build:
        sp.check_call(["make", "clean"])
        sp.check_call(["make", "build"])

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

    # Pare it down to just the smallest size per benchmark for a test run.
    if args.test:
        params = {k: [v[0]] for k, v in PARAMETERS.items()}
    else:
        params = PARAMETERS

    if args.skiplargemem:
        # Filter out large QR decompositions
        params[qrdecomp] = filter(lambda k: int(k["N"]) < 4, params[qrdecomp])

    if not args.skipsynth:
        for b in benchmarks:
            synthesize_benchmark(cur_results_dir, b, args.timeout, params, args.validation)

    if args.validation and args.skipsynth:
        for b in benchmarks:
            only_validation(cur_results_dir, b)

    if not args.skiprun:
        for b in benchmarks:
            run_benchmark(cur_results_dir, b, args.build, args.force)

if __name__ == main():
    main()
