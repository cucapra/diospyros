"""

  GTest and benchmark generator to validate generated kernels from diospyros
  tool again specification

  This script generates the code for the main benchmark binary and GTest by
  stiching together the generated kernel calls with the scaffolding required
  Since some code is redundant between the two the files are generated
  simultaneously

"""

from utils import clang_format
from manifest import *


def test_generator(manifest_data, test_file, benchmark_file):

    baseline_exists = TEST_CODE in manifest_data
    gtest = open(test_file, "w")
    benchmark = open(benchmark_file, "w")
    headers = """
#include <Eigen>
#include <Eigen/Dense>
#include <Eigen/Core>

#include <{}.h>
#include <utils.h>
#include <fstream>
#include <iostream>

#define TOLERANCE {}

""".format(
        manifest_data[NAME], DEFAULT_TEST_TOLERANCE
    )
    gtest.write("#include <gtest/gtest.h>\n")
    gtest.write(headers)
    benchmark.write(headers)

    # Write out the test headers and main signature
    gtest.write("TEST(DiospyrosTests, {}Test)".format(
        manifest_data[NAME]) + "{\n")
    benchmark.write("int main(int argc, char** argv) {\n")

    # Define the input variables based on the manifest definitions
    spec_args = ""
    synth_args = ""
    var_defs = ""
    for arg in manifest_data[INPUTS]:
        v = arg
        t = manifest_data[INPUTS][v]
        var_defs += "{} {} = {}::Random();\n".format(t, v, t)
        spec_args += "{}.data(), ".format(v)
        synth_args += "{}.data(), ".format(v)

    # Define the output variables based on the manifest definitions
    for arg in manifest_data[OUTPUTS]:
        v = arg
        t = manifest_data[OUTPUTS][v]
        var_defs += ("{} {}; // expected \n".format(t, v) if baseline_exists else
                     "")
        var_defs += "{} {}SpecResult;\n".format(t, v)
        var_defs += "{} {}SynthResult;\n".format(t, v)
        spec_args += "{}SpecResult.data(),".format(v)
        synth_args += "{}SynthResult.data(),".format(v)
    spec_args = spec_args.strip(",")  # strip trailing comma
    synth_args = synth_args.strip(",")  # strip trailing comma

    gtest.write(var_defs)
    benchmark.write(var_defs)

    # only write out baseline code if it is provided in manifest
    if baseline_exists:
        baseline_code = "{};\n".format(manifest_data[TEST_CODE])

    # call the specification code
    specification_code = "diospyros::specification::{}({});\n".format(
        manifest_data[SPECIFICATION_KERNEL], spec_args
    )

    # call the synthesized code
    synthesized_code = "diospyros::{}({});\n".format(
        manifest_data[NAME], synth_args)

    # write out code blocks to test case
    if baseline_exists:
        gtest.write(baseline_code)
    gtest.write(specification_code)
    gtest.write(synthesized_code)

    # instantiate timer and file I/O for the results file
    benchmark.write("""
        int time = 0;

        std::ofstream results("results.json", std::ofstream::out);
        results << "{";
    """)

    # write out timing instrumentation for baseline call only if it exists
    if baseline_exists:
        benchmark.write(
            """
    start_cycle_timing;
    {}
    stop_cycle_timing;
    time = get_time();
    printf("Unoptimized Eigen cycles: %d\\n", time);
    results << "\\"baseline\\" :" << time << "," << std::endl;
    """.format(baseline_code)
        )

    # write out the calls to the specification and optimized version
    benchmark.write(
        """
    // Unoptimized call time
    start_cycle_timing;
    {}
    stop_cycle_timing;
    time = get_time();
    printf("Unoptimized Specification cycles: %d\\n", time);
    results << "\\"unoptimized\\" :" << time << "," << std::endl;

    // Optimized call time
    start_cycle_timing;
    {}
    stop_cycle_timing;
    time = get_time();
    printf("Optimized Specification cycles: %d\\n", time);
    results << "\\"optimized\\" :" << time << std::endl;

    """.format(
            specification_code, synthesized_code
        )
    )

    # generate the validation statements to check that outputs approximately
    # match
    for arg in manifest_data[OUTPUTS]:
        gtest.write(
            """
            EXPECT_TRUE({}SpecResult.isApprox({}SynthResult));
            """.format(arg, arg)
        )
        benchmark.write("""
        if (!{}SpecResult.isApprox({}SynthResult)) {{
           printf("Benchmark specification result and synthesis output does not
           match for {}\\n");
           std::cout << "Specification: " << {}SpecResult << std::endl;
           std::cout << "Baseline: " << {}SynthResult << std::endl;
        }}""".format(arg, arg, arg, arg, arg))

        # only write output validation if the baseline code exists
        if baseline_exists:
            gtest.write("""
            EXPECT_TRUE({}.isApprox({}SpecResult)));
            """.format(arg, arg))
            benchmark.write("""
            if (!{}.isApprox({}SpecResult)) {{
               printf("Benchmark specification result and baseline result does not match for {}\\n");
               std::cout << "Specification: " << {}SpecResult << std::endl;
               std::cout << "Baseline: " << {} << std::endl;
            }}
            """.format(arg, arg, arg, arg, arg))

    # write out terminating statements
    gtest.write("}\n")
    benchmark.write("""
        results << "}";
        results.close();
        return 0;
        }""")

    gtest.close()
    benchmark.close()

    # clang format the files
    clang_format(test_file)
    clang_format(benchmark_file)
