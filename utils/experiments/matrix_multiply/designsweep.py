#!/usr/bin/env python3

"""

  Driver script to run matrix multiply experiments

"""

import os
import json
from subprocess import Popen, PIPE
import datetime

RESULT_FILE = "results.json"
XTENSA_CORE = "XTENSA_CORE"
DEVICE_TARGET = "FUSION_G3"

if __name__ == "__main__":
    if XTENSA_CORE not in os.environ:
        # define this to pass to Makefile builds
        os.environ["XTENSA_CORE"] = DEVICE_TARGET

    # set the range of matrix multiplication parameters here
    input_rows = range(1, 9)
    input_cols = range(1, 9)
    output_cols = range(1, 9)

    results = dict()
    ts = datetime.datetime.now()
    report_file = "sweep_{}_{}_{}_{}_{}_{}.json".format(ts.year, ts.month,
                                                        ts.day, ts.hour, ts.minute, ts.second)

    root = os.getcwd()

    tests = 0

    for ir in input_rows:
        for ic in input_cols:
            for oc in output_cols:

                build_dir = "build_{}x{}x{}x{}".format(ir, ic, ic, oc)
                test_failure = False

                # shortcut the test if the build exists and results exist
                if os.path.exists(os.path.join
                                  (build_dir, RESULT_FILE)):
                    os.chdir(build_dir)
                # execute the full build test otherwise
                else:
                    cmd = """eigen.py --kernel multiply --input_rows {} --input_cols {} \
              --output_cols {} --build_dir {}""".format(ir, ic, oc, build_dir)
                    os.system(cmd)

                    # change to build directory
                    if os.path.exists(build_dir):
                        os.chdir(build_dir)
                    else:
                        print("Error: Cannot find build directory {}".format
                              (build_dir))
                        exit(-1)

                    # execute test
                    test_cmd = "make test"
                    os.system(test_cmd)

                    # run the test in simulation
                    xt_cmd = "make sim"

                    p = Popen(xt_cmd.split(), stdin=PIPE,
                              stdout=PIPE, stderr=PIPE)
                    output, err = p.communicate(
                        b"input data that is passed to subprocess' stdin")

                    # check if the GTest validation failed
                    test_failure = True if "FAILED" in str(output) else False

                    # execute benchmark
                    benchmark_cmd = "make benchmark"
                    os.system(benchmark_cmd)

                    xt_cmd = ("xt-run --xtensa-core=FCV_FG3 {}".format
                              ("benchmark"))
                    os.system(xt_cmd)

                # scrape the resulting json file and load the results
                perf = dict()
                try:
                    handle = open("results.json", "r")
                    perf = json.load(handle)
                    handle.close()
                except:
                    test_failure = True

                perf["Test Failure"] = test_failure

                if ir not in results:
                    results[ir] = dict()
                if ic not in results[ir]:
                    results[ir][ic] = dict()
                results[ir][ic][oc] = perf

                os.chdir(root)

                # dump the results every 10 runs
                if (tests % 10 == 0):
                    out_handle = open(report_file, "w")
                    json.dump(results, out_handle)
                    out_handle.close()
                tests += 1

    # write out the final results
    out_handle = open(report_file, "w")
    json.dump(results, out_handle)
    out_handle.close()
