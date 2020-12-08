"""

  GTest and benchmark generator to validate generated kernels from diospyros
  tool again specification

"""

from utils import clang_format
from manifest import *


def test_generator(manifest_data, test_file, benchmark_file):

    baseline_exists = TEST_CODE in manifest_data
    gtest = open(test_file, "w")
    benchmark = open(benchmark_file, "w")
    headers = """
#include <Eigen>

#include <{}.h>
#include <utils.h>

#define TOLERANCE {}

""".format(
        manifest_data[NAME], DEFAULT_TEST_TOLERANCE
    )
    gtest.write("#include <gtest/gtest.h>\n")
    gtest.write(headers)
    benchmark.write(headers)

    gtest.write("TEST(DiospyrosTests, {}Test)".format(
        manifest_data[NAME]) + "{\n")
    benchmark.write("int main(int argc, char** argv) {\n")

    spec_args = ""
    synth_args = ""
    var_defs = ""
    for arg in manifest_data[INPUTS]:
        v = arg
        t = manifest_data[INPUTS][v]
        var_defs += "{} {} = {}::Random();\n".format(t, v, t)
        spec_args += "{}.data(), ".format(v)
        synth_args += "{}.data(), ".format(v)

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

    specification_code = "diospyros::specification::{}({});\n".format(
        manifest_data[SPECIFICATION_KERNEL], spec_args
    )
    synthesized_code = "diospyros::{}({});\n".format(
        manifest_data[NAME], synth_args)

    # write out to test case
    if baseline_exists:
        gtest.write(baseline_code)
    gtest.write(specification_code)
    gtest.write(synthesized_code)

    # instantiate timer
    benchmark.write("int time = 0;")

    # write out timing instrumentation
    if baseline_exists:
        benchmark.write(
            """
    start_cycle_timing;
    {}
    stop_cycle_timing;
    time = get_time();
    printf("Unoptimized Eigen cycles: %d\\n", time);
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

    // Optimized call time
    start_cycle_timing;
    {}
    stop_cycle_timing;
    time = get_time();
    printf("Optimized Specification cycles: %d\\n", time);

    """.format(
            specification_code, synthesized_code
        )
    )

    for arg in manifest_data[OUTPUTS]:
        gtest.write(
            """
            EXPECT_TRUE({}SpecResult.isApprox({}SynthResult));
            """.format(arg, arg)
        )
        benchmark.write("""
        if (!{}SpecResult.isApprox({}SynthResult)) {{
           printf("Benchmark specification result and synthesis output does not match for {}");
        }}""".format(arg, arg, arg))

        if baseline_exists:
            gtest.write("""
            EXPECT_TRUE({}.isApprox({}SpecResult)));
            """.format(arg, arg))
            benchmark.write("""
            if (!{}.isApprox({}SpecResult)) {{
               printf("Benchmark specification result and baseline result does not match for {}");
            }}
            """.format(arg, arg, arg))

    gtest.write("}\n")
    benchmark.write("return 0;\n}\n")

    gtest.close()
    benchmark.close()

    # clang format the files
    clang_format(test_file)
    clang_format(benchmark_file)
