#!/usr/bin/env python3

# Generator script to launch the Diospyros compiler for different code kernel
# dimensions

import argparse
import os
import subprocess

import arguments
from manifest import *
from test import *
from utils import *
from source import *

# only import if a build.py is defined for how to generate build files
try:
    from build import *
except:
    pass

# TODO: make sure @generated tag is added to files

DIOSPYROS_ERROR_CODE = 255
CDIOS_BINARY = "cdios"
GENERATED_KERNEL_DIR = "compile-out"
GENERATED_KERNEL_FILE = "kernel.c"
GENERATED_PREPROCESSED_FILE = "preprocessed.c"
COMMON_HEADER_DIRECTORY = os.path.join(
    os.path.dirname(os.path.realpath(__file__)), "include"
)


def driver():
    """ Driver function which loads manifest data and configurations for the
    compilation
    """

    parser = argparse.ArgumentParser(
        description="Wrapper script around the Diospyros DSP kernel optimization synthesis tool."
    )

    # configure command line arguments
    arguments.add_arguments(parser)
    args = parser.parse_args()

    manifest_file = str(args.manifest[0])
    manifest_data = load_manifest(manifest_file)
    manifest_data[MANIFEST_PATH] = os.path.dirname(
        os.path.realpath(manifest_file))
    return generate(manifest_data)


def generate(manifest_data):
    """ Generator routine that executes the compilation and converts file into a
    usable sel-contained build that can be imported
    """

    spec_file = os.path.realpath(
        os.path.join(manifest_data[MANIFEST_PATH],
                     manifest_data[SPECIFICATION])
    )
    if not os.path.exists(spec_file):
        print(
            "Error: Manifest file searching for specification file: \
            {}".format(
                spec_file
            )
        )
        exit(DIOSPYROS_ERROR_CODE)

    kernel_name = manifest_data[NAME] if NAME in manifest_data else DEFAULT_KERNEL_NAME

    # attempt compilation by invoking the diospyros tool
    cmd = "{} --name {} {}".format(CDIOS_BINARY, kernel_name, spec_file)
    exit_code = os.system(cmd)
    return_code = os.WEXITSTATUS(exit_code)
    if return_code != 0:
        print(
            "Error: Compilation aborted. {} return error code {}.".format(
                CDIOS_BINARY, return_code
            )
        )
        return return_code

    # set some default arguments if they are not defined
    if BUILD_DIR not in manifest_data:
        manifest_data[BUILD_DIR] = kernel_name
    if SRC_DIR not in manifest_data:
        manifest_data[SRC_DIR] = os.path.join(
            manifest_data[BUILD_DIR], DEFAULT_SRC_DIR)
    if INCLUDE_DIR not in manifest_data:
        manifest_data[INCLUDE_DIR] = os.path.join(
            manifest_data[BUILD_DIR], DEFAULT_INCLUDE_DIR
        )
    if BIN_DIR not in manifest_data:
        manifest_data[BIN_DIR] = os.path.join(
            manifest_data[BUILD_DIR], DEFAULT_BIN_DIR)
    manifest_data[TEST_DIR] = os.path.join(
        manifest_data[BUILD_DIR], DEFAULT_TEST_DIR)

    # create paths to folders if they do not exist
    for x in [SRC_DIR, INCLUDE_DIR, BIN_DIR, TEST_DIR]:
        path = manifest_data[x]
        if not os.path.exists(path):
            os.makedirs(path)

    # copy out the files from the compiled directory to the build directory
    source_file = os.path.join(
        manifest_data[SRC_DIR], "{}.cpp".format(kernel_name))
    header_file = os.path.join(
        manifest_data[INCLUDE_DIR], "{}.h".format(kernel_name))
    kernel_file = os.path.join(GENERATED_KERNEL_DIR, GENERATED_KERNEL_FILE)
    spec_file = os.path.join(GENERATED_KERNEL_DIR, GENERATED_PREPROCESSED_FILE)
    test_file = os.path.join(manifest_data[TEST_DIR], "test.cpp")
    benchmark_file = os.path.join(manifest_data[BIN_DIR], "benchmark.cpp")

    # takes the generated kernels source files and emits include and src
    # directories
    source_generator(source_file, kernel_file, spec_file)

    # TODO: Currently a hack since tool does not generate header signatures
    cmd = "mv {} {}".format(source_file, header_file)
    os.system(cmd)

    # generates the GTest and benchmarking binary
    test_generator(manifest_data, test_file, benchmark_file)

    # generate the build files if a build generator definition exists
    try:
        build_generator(
            manifest_data, manifest_data[BUILD_DIR], target=kernel_name)
    except:
        pass  # ignore if the build generator routine is not defined

    return 0


if __name__ == "__main__":
    exit_code = driver()
    exit(exit_code)
