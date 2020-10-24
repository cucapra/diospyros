#!/usr/bin/env python3

import click
import os
import subprocess
import sys

INTERMEDIATE = "compile-out"

@click.command()
@click.argument('spec_file',
    type=click.Path(exists=True),
    metavar='<spec_file>')
def cdios(spec_file):
    """Takes a specification file, written in C, and:
        - Sanity check that it compiles with GCC
        - Translates it to equivalence Racket (best effort)
        - Uses Diospyros' equality saturation engine to find vectorization
        - Emits C with Tensilica DSP intrinsics
    """

    # Fully quantify the specification file path
    spec_file = os.path.realpath(spec_file)

    # Force CWD directory to land in diospyros root
    script_path = os.path.dirname(os.path.realpath(__file__))
    cwd = os.getcwd()
    os.chdir(script_path)

    # Attempt to run gcc
    cmd = subprocess.run(["gcc", "-S", spec_file, "-o", "/dev/null"], stdout=subprocess.PIPE, stderr=subprocess.PIPE)

    # Bail early if GCC fails to compile
    # (note: don't assemble since we might not have a main function)
    if cmd.returncode:
        sys.stdout.write(cmd.stderr.decode("utf-8"))
        exit(1)
    else:
        print("Standard C compilation successful")
        print("Writing intermediate files to: {}".format(INTERMEDIATE))

    # Nuke output directory contents
    subprocess.run(["rm", "-rf", INTERMEDIATE], stderr=subprocess.STDOUT)
    subprocess.run(["mkdir", INTERMEDIATE], stderr=subprocess.STDOUT)

    # Preprocess to handle #defines, etc
    cmd = subprocess.run(["gcc", "-E", spec_file, "-o", os.path.join(INTERMEDIATE, "preprocessed.c")])
    if cmd.returncode:
        if cmd.stdout:
            sys.stdout.write(cmd.stdout.decode("utf-8"))
        if cmd.stderr:
            sys.stdout.write(cmd.stderr.decode("utf-8"))
        exit(1)

    # Remove preprocessing header
    subprocess.run(["sed", "/^#/d", "-i", os.path.join(INTERMEDIATE, "preprocessed.c")])

    # Run conversion to Racket
    cmd = subprocess.run(['racket', 'src/c-meta.rkt'], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    if cmd.returncode:
        sys.stdout.write(cmd.stderr.decode("utf-8"))
        exit(1)

    subprocess.run(["make", "compile-egg"], stderr=subprocess.STDOUT)
    subprocess.run(["cat", os.path.join(INTERMEDIATE, "kernel.c")])

    # Go back to where launched from and copy out result files
    subprocess.run(["cp", "-r", INTERMEDIATE, cwd])
    os.chdir(cwd)

if __name__ == '__main__':
    cdios()
