"""

Define manifest fields for specification

"""

import json


NAME = "name"
NAMESPACE = "namespace"
INPUTS = "inputs"
OUTPUTS = "outputs"
SPECIFICATION = "specification"
BUILD_DIR = "build_dir"
BUILD_NAME = "build_name"
SRC_DIR = "src_dir"
INCLUDE_DIR = "include_dir"
TEST_DIR = "test_dir"
BUCK_FILE = "BUCK"
BIN_DIR = "bin"
HEADER_FILE = "header"
TEST_CODE = "test"
TYPE = "type"
ROWS = "rows"
COLS = "cols"

REQUIRED_FIELDS = [NAME, INPUTS, OUTPUTS, SPECIFICATION]

DEFAULT_KERNEL_NAME = "kernel"
DEFAULT_BUILD_DIR = "build"
DEFAULT_BUILD_NAME = "diospyros_default"
DEFAULT_SRC_DIR = "src"
DEFAULT_INCLUDE_DIR = "include"
DEFAULT_BIN_DIR = "bin"
DEFAULT_TEST_DIR = "test"
DEFAULT_NAMESPACE = "diospyros"
DEFAULT_BUCK_TARGET = "lib"
DEFAULT_TEST_TOLERANCE = 1e-5
SPECIFICATION_NAMESPACE = "specification"
SPECIFICATION_KERNEL = "specification_kernel"  # the specification function name
MANIFEST_PATH = "manifest_path"

# takes in a manifest file path and attempts to load it while checking to ensure
# valid fields


def load_manifest(manifest_file):
    try:
        read_handle = open(manifest_file)
        manifest_data = json.load(read_handle)
        read_handle.close()

        for required in REQUIRED_FIELDS:
            if required not in manifest_data:
                print(
                    "Error: Required manifest field {} not found in manifest {}.".format(
                        required, manifest_data
                    )
                )
                exit(-1)

        return manifest_data

    except IOError:
        print("Warning: Manifest {} could not be read".format(manifest_file))
