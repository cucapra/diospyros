#!/usr/bin/env python3

import click
import os
import subprocess
import sys

class colors:
    HEADER = '\033[95m'
    OKBLUE = '\033[94m'
    OKCYAN = '\033[96m'
    OKGREEN = '\033[92m'
    WARNING = '\033[93m'
    FAIL = '\033[91m'
    ENDC = '\033[0m'
    BOLD = '\033[1m'
    UNDERLINE = '\033[4m'

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
@click.option('--color/--no-color',
    default=True,
    help='Colored terminal output')

def cdios(spec_file, name, inter, debug, git, color):
    """Takes a specification file, written in C, and:
        - Sanity check that it compiles with GCC
        - Translates it to equivalence Racket (best effort)
        - Uses Diospyros' equality saturation engine to find vectorization
        - Emits C with Tensilica DSP intrinsics
    """

    def cdios_error(arg):
        if color:
            print(colors.FAIL + arg + colors.ENDC)
        else:
            print(arg)

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
    cmd = subprocess.run(["gcc", "-Wno-implicit-function-declaration", "-std=c99", "-S", spec_file, "-o", "/dev/null"], stdout=subprocess.PIPE, stderr=subprocess.PIPE)

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
    cmd = subprocess.run(["gcc", "-Wno-implicit-function-declaration", "-E", spec_file, "-o", preprocessed])
    if cmd.returncode:
        if cmd.stdout:
            sys.stdout.write(cmd.stdout.decode("utf-8"))
        if cmd.stderr:
            sys.stdout.write(cmd.stderr.decode("utf-8"))
        exit(1)

    # Remove preprocessing header
    subprocess.run(["sed", "/^#/d", "-i", os.path.join(intermediate, "preprocessed.c")])

    # Run conversion to Racket
    cmd = subprocess.run(['racket', 'src/c-meta.rkt', intermediate], stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    if cmd.returncode:
        cdios_error("CDIOS: Compiling C->Racket failed")
        cdios_error(cmd.stdout.decode("utf-8"))
        exit(1)
    elif debug:
        sys.stdout.write(cmd.stdout.decode("utf-8"))

    if not (os.path.exists("./dios") and os.path.exists("./dios-example-gen")):
        subprocess.run(["make", "build"])

    flags = "BACKEND_FLAGS=-n {}".format(name)
    if not git:
        flags += " --suppress-git"

    cmd = subprocess.run(["make", "{}-egg".format(file_name), flags], stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    if cmd.returncode:
        cdios_error("CDIOS: Rewriting or backend compilation failed")
        cdios_error(cmd.stdout.decode("utf-8"))
        exit(1)
    elif debug:
        sys.stdout.write(cmd.stdout.decode("utf-8"))
    subprocess.run(["cat", os.path.join(intermediate, "kernel.c")])

    # Go back to where launched from and copy out result files
    subprocess.run(["cp", "-r", intermediate, cwd])
    os.chdir(cwd)

if __name__ == '__main__':
    cdios()
