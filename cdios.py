#!/usr/bin/env python3

import click
import subprocess
import sys

@click.command()
@click.option('--intermediate',
    click.Path(exists=True),
    metavar='<dir>',
    default='make',
    help='command to build submissions')
@click.argument('spec_file',
    type=click.Path(exists=True),
    metavar='<spec_file>')
def cdios(spec_file, intermediate):
    """Takes a specification file, written in C, and:
        - Sanity check that it compiles with GCC
        - Translates it to equivalence Racket (best effort)
        - Uses Diospyros' equality saturation engine to find vectorization
        - Emits C with Tensilica DSP intrinsics
    """
    # Attempt to run gcc
    cmd = subprocess.run(["gcc", "-S", spec_file, "-o", "/dev/null"], stdout=subprocess.PIPE, stderr=subprocess.PIPE)

    # Bail early if GCC fails to compile
    # (note: don't assemble since we might not have a main function)
    if cmd.returncode:
        sys.stdout.write(cmd.stderr.decode("utf-8"))
        exit(1)
    else:
        print("Standard C compilation successful")
        print("Writing intermediate files to:".format)

    # Nuke output directory contents
    subprocess.run(["rm", "-rf", "compile-out/*"], stderr=subprocess.STDOUT)

    # Preprocess to handle #defines, etc
    subprocess.run(["gcc", "-E", "tmp.c", "-o", "compile-out/preprocess-tmp.c"])

    # Remove preprocessing header
    subprocess.run(["sed", "/^#/d", "-i", "compile-out/preprocess-tmp.c"])

    # Run conversion to Racket
    cmd = subprocess.run(['racket', 'src/c-meta.rkt'], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    if cmd.returncode:
        sys.stdout.write(cmd.stderr.decode("utf-8"))
        exit(1)

    subprocess.run(["make", "compile-egg"], stderr=subprocess.STDOUT)
    subprocess.run(["cat", "compile-out/kernel.c"])

if __name__ == '__main__':
    cdios()
