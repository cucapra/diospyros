#!/usr/bin/env python3

import click
import os
import subprocess
import sys

def eprint(*args, **kwargs):
    print(*args, file=sys.stderr, **kwargs)

@click.command()
@click.argument('spec_file',
    type=click.Path(exists=True),
    metavar='<spec_file>')
@click.option('--name',
    type=str,
    metavar='<name>',
    default='kernel',
    help='Name of the kernel function in the generated C')
@click.option('--inter',
    is_flag=True,
    default=False,
    help='Use a name-based intermediate directory')
@click.option('--debug',
    is_flag=True,
    default=False,
    help='Verbose debug output')
@click.option('--git/--no-git',
    default=True,
    help='Include git info comment in the generated C')

def cdios(spec_file, name, inter, debug, git):
    """Takes a specification file, written in C, and:
        - Sanity check that it compiles with GCC
        - Translates it to equivalence Racket (best effort)
        - Uses Diospyros' equality saturation engine to find vectorization
        - Emits C with Tensilica DSP intrinsics
    """

    # Fully quantify the specification file path
    spec_file = os.path.realpath(spec_file)

    # Intermediate
    if inter:
        file_name = os.path.splitext(os.path.basename(spec_file))[0]
    else:
        file_name = "compile"

    intermediate = file_name + "-out"

    # Force CWD directory to land in diospyros root
    script_path = os.path.dirname(os.path.realpath(__file__))
    cwd = os.getcwd()
    os.chdir(script_path)

    # Attempt to run gcc
    cmd = subprocess.run(["gcc", "-std=c99", "-S", spec_file, "-o", "/dev/null"], stdout=subprocess.PIPE, stderr=subprocess.PIPE)

    # Bail early if GCC fails to compile
    # (note: don't assemble since we might not have a main function)
    if cmd.returncode:
        sys.stdout.write(cmd.stderr.decode("utf-8"))
        exit(1)
    else:
        eprint("Standard C compilation successful")
        eprint("Writing intermediate files to: {}".format(intermediate))

    # Nuke output directory contents
    subprocess.run(["rm", "-rf", intermediate], stderr=subprocess.STDOUT)
    subprocess.run(["mkdir", intermediate], stderr=subprocess.STDOUT)

    # Preprocess to handle #defines, etc
    preprocessed = os.path.join(intermediate, "preprocessed.c")
    cmd = subprocess.run(["gcc", "-E", spec_file, "-o", preprocessed])
    if cmd.returncode:
        if cmd.stdout:
            sys.stdout.write(cmd.stdout.decode("utf-8"))
        if cmd.stderr:
            sys.stdout.write(cmd.stderr.decode("utf-8"))
        exit(1)

    # Remove preprocessing header
    subprocess.run(["sed", "/^#/d", "-i", os.path.join(intermediate, "preprocessed.c")])

    # Run conversion to Racket
    if debug:
        cmd = subprocess.run(['racket', 'src/c-meta.rkt', intermediate])
    else:
        cmd = subprocess.run(['racket', 'src/c-meta.rkt', intermediate], stdout=subprocess.DEVNULL, stderr=subprocess.PIPE)
    if cmd.returncode:
        sys.stdout.write(cmd.stderr.decode("utf-8"))
        exit(1)

    flags = "BACKEND_FLAGS=-n {}".format(name)
    if not git:
        flags += " --suppress-git"
    if debug:
        subprocess.run(["make", "{}-egg".format(file_name), flags])
    else:
        subprocess.run(["make", "{}-egg".format(file_name), flags], stdout=subprocess.DEVNULL, stderr=subprocess.PIPE)
    subprocess.run(["cat", os.path.join(intermediate, "kernel.c")])

    # Go back to where launched from and copy out result files
    subprocess.run(["cp", "-r", intermediate, cwd])
    os.chdir(cwd)

if __name__ == '__main__':
    cdios()
