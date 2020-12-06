"""

  Utility function definitions

"""

import subprocess
import os


def clang_format(file):
    # clang format the files
    formatted = subprocess.check_output(["clang-format", file])
    tmp_file = "{}.tmp".format(file)
    handle = open(tmp_file, "w")
    handle.write(formatted.decode("utf-8"))
    handle.close()

    # remove temporary source file
    cmd = "mv {} {}".format(tmp_file, file)
    os.system(cmd)
