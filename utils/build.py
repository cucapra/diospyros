# Prepare and add the build infrastructure for the kernel generated

import os
from os.path import join, dirname, realpath

# assume generic Makefile lives at the same directory as this source file
STOCK_MAKEFILE = join(dirname(realpath(__file__)), "Makefile")


def build_generator(manifest_data, build_dir, target):

    # copy out the stock Makefile to the build directory
    assert(os.path.exists(build_dir))
    assert(os.path.exists(STOCK_MAKEFILE))

    cmd = "cp {} {}".format(STOCK_MAKEFILE, build_dir)
    print(cmd)
    os.system(cmd)
