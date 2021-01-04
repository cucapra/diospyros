"""

    Generator for source files to be compiled for the generated kernels

"""

from manifest import *
import subprocess
import os


def source_generator(
    source_file, kernel_file, specification_file, namespace=DEFAULT_NAMESPACE
):

    source = ""

    source += "namespace {}".format(namespace) + " {\n"
    source += "namespace {}".format(SPECIFICATION_NAMESPACE) + " {\n"

    spec_handle = open(specification_file)
    spec = spec_handle.read()
    source += spec
    spec_handle.close()
    source += "}\n"

    kernel_handle = open(kernel_file)
    kernel = kernel_handle.readlines()
    includes = ""
    for line in kernel:
        if "#include" in line:
            includes += line
        else:
            source += line
    source = includes + source  # TODO: hack to force headers outside namespace
    kernel_handle.close()

    source += "}\n"

    # write out unformatted file
    tmp_file = "{}.tmp".format(source_file)
    tmp_source = open(tmp_file, "w")
    tmp_source.write(source)
    tmp_source.close()

    # clang format the file
    formatted = subprocess.check_output(["clang-format", tmp_file])

    # write out the file source file
    handle = open(source_file, "w")
    handle.write(formatted.decode("utf-8"))
    handle.close()

    # remove temporary source file
    cmd = "rm -f {}".format(tmp_file)
    os.system(cmd)
