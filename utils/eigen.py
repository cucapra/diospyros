#!/usr/bin/env python3

"""

  Eigen kernel generator script. Autogenerates the specifications for various Eigen operator operations which can then be used to overload the operator+ and operator* operations.

"""

import argparse
import os
import diospyros
from manifest import *
from diospyros import DIOSPYROS_ERROR_CODE
from generators import matrix_multiply

KERNELS = ["multiply", "add"]


def add_arguments(args):
    args.add_argument("--input_rows",
                      metavar="input_rows",
                      type=int,
                      nargs=1,
                      default=3,
                      help="Number of input matrix rows."
                      )
    args.add_argument("--input_cols",
                      metavar="input_cols",
                      type=int,
                      nargs=1,
                      default=3,
                      help="Number of input matrix columns.")
    args.add_argument("--output_cols",
                      metavar="output_cols",
                      type=int,
                      nargs=1,
                      default=3,
                      help="Number of output matrix columns."
                      )
    args.add_argument("--kernel", metavar="kernel", type=str, nargs=1,
                      required=True,
                      help="""Specifies which kernel type to emit. This will
                      dictate which generator is invoked. Supported options: {}""".format(str(KERNELS)))
    args.add_argument("--build_dir", metavar="build_dir", type=str, nargs=1,
                      default=["build"])


def driver():

    parser = argparse.ArgumentParser(
        description="Eigen kernel generator script."
    )
    add_arguments(parser)
    args = parser.parse_args()

    params = dict()

    params["input_rows"] = int(args.input_rows)
    params["input_cols"] = int(args.input_cols)
    params["output_cols"] = int(args.output_cols)
    params[BUILD_DIR] = str(args.build_dir[0])

    # identify the kernel type
    kernel = str(args.kernel[0])

    # generate the build directory
    if not os.path.exists(params[BUILD_DIR]):
        os.mkdir(params[BUILD_DIR])
    if not os.path.exists(os.path.join(params[BUILD_DIR], DEFAULT_SPEC_DIR)):
        os.mkdir(os.path.join(params[BUILD_DIR], DEFAULT_SPEC_DIR))

    manifest_path = os.path.join(params[BUILD_DIR], DEFAULT_SPEC_DIR)
    spec_file = "specification.c"

    # switch based on the kernel
    kernel_name = None
    manifest_data = None
    if (kernel == "multiply"):
        kernel_name = "MatMult{}x{}x{}x{}".format(params["input_rows"], params
                                                  ["input_cols"], params["input_cols"], params["output_cols"])
        manifest_data = matrix_multiply.generator(kernel_name,
                                                  params,
                                                  os.path.join
                                                  (manifest_path,
                                                   spec_file))
    elif (kernel == "add"):
        raise NotImplementedError("Not implemented")
    else:
        print("Error: Kernel type {} does not exist.".format(kernel))
        exit(DIOSPYROS_ERROR_CODE)

    # add remaining fields to manifest file to populate it
    manifest_data[NAME] = kernel_name
    manifest_data[NAMESPACE] = "Eigen"
    manifest_data[SPECIFICATION] = spec_file
    manifest_data[SPECIFICATION_KERNEL] = kernel_name
    manifest_data[MANIFEST_PATH] = manifest_path
    manifest_data[BUILD_DIR] = params[BUILD_DIR]

    # invoke the wrapper to generate the kernels
    exit_code = diospyros.generate(manifest_data)

    # generate the manifest associated with this build for reproducibility
    manifest_file = os.path.join(
        manifest_data[MANIFEST_PATH], "diospyros.json")
    manifest_handle = open(manifest_file, "w")
    manifest_handle.write(json.dumps(manifest_data))
    manifest_handle.close()

    return exit_code


if __name__ == "__main__":
    exit_code = driver()
    exit(exit_code)
