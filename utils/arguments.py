"""

Arguments to argparse definitions

"""

import argparse


def add_arguments(args):
    args.add_argument(
        "--manifest",
        metavar="manifest",
        required=True,
        type=str,
        nargs=1,
        help="Specifies the manifest file to invoke the diospyros tool with. The manifest file contains the metadata associated with the build and synthesis formulation",
    )
    args.add_argument(
        "--debug",
        action="store_true",
        help="Turns on the debug mode for this script and does not invoke any of the system calls.",
    )
