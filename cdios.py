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

def clang_format(contents):
    tmp = ".clang-format.tmp"
    with open(tmp, 'w') as f:
        f.write(contents)
    formatted = subprocess.check_output(["clang-format", tmp])
    os.remove(tmp)
    return formatted.decode("utf-8")

def header_and_namespace(name, output_path, cdios_success):
    with open(os.path.join(output_path, "preprocessed.c"), 'r') as file:
        spec = file.readlines()

    with open(os.path.join(output_path, "kernel.c"), 'r') as file:
        dios_lines = file.readlines()

    decl = [l.replace(" {", ";") for l in dios_lines if l.startswith('void')][0]

    namespacing = """
        namespace diospyros {{

        {}

        }} // namespace diospyros

        namespace specification {{

        {}

        }} // namespace specification
    """

    header = namespacing.format(decl, decl)
    formatted = clang_format(header)
    header_path = os.path.join(output_path,"{}.h".format(name))
    with open(header_path, 'w') as f:
        f.write(formatted)
    cdios_success("Header written to {}".format(header_path))


    xtensa_guard  = """
        #if defined(__XTENSA__)
        {}
        #endif // defined(__XTENSA__)
    """

    imports = [l for l in dios_lines if l.startswith('#include')]
    xtensa_imports = [l for l in imports if "xtensa" in l]
    std_imports = [l for l in imports if "xtensa" not in l]
    imports = "".join(std_imports)
    imports += xtensa_guard.format("".join(xtensa_imports))

    dios_rest = [l for l in dios_lines if not l.startswith('#include')]
    implementation = "".join(imports)
    dios_impl = xtensa_guard.format("".join(dios_rest))
    implementation += namespacing.format(dios_impl, "".join(spec))
    formatted = clang_format(implementation)
    impl_path = os.path.join(output_path,"{}.c".format(name))
    with open(impl_path, 'w') as f:
        f.write(formatted)
    cdios_success("Implementation written to {}".format(impl_path))


@click.command()
@click.argument('spec_file',
    type=click.Path(exists=True),
    metavar='<spec_file>')
@click.option('--name',
    type=str,
    metavar='<name>',
    default='kernel',
    help='Name of the kernel function in the generated C')
@click.option('--function',
    type=str,
    metavar='<function>',
    help='Name of the function to optimize')
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
@click.option('--header/--no-header',
    default=True,
    help='Emit code with a header file and namespacing')

def cdios(spec_file, name, function, inter, debug, git, color, header):
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

    def cdios_success(arg):
        if color:
            print(colors.OKGREEN + arg + colors.ENDC)
        else:
            print(arg)

    # Fully quantify the specification file path
    spec_file = os.path.realpath(spec_file)

    # Intermediate
    if inter:
        file_name = os.path.splitext(os.path.basename(spec_file))[0]
    else:
        file_name = "compile"


    # If function specified, use that as name
    if function and (name == 'kernel'):
        name = function

    build_dir = "build"
    if not os.path.exists(build_dir):
        os.makedirs(build_dir)
    intermediate = os.path.join(build_dir, file_name + "-out")

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
    gcc_cmd = [
        "gcc",
        "-std=c99",
        "-pedantic",
        "-Wno-implicit-function-declaration",
        "-E", spec_file,
        "-o", preprocessed
    ]
    cmd = subprocess.run(gcc_cmd)
    if cmd.returncode:
        if cmd.stdout:
            sys.stdout.write(cmd.stdout.decode("utf-8"))
        if cmd.stderr:
            sys.stdout.write(cmd.stderr.decode("utf-8"))
        exit(1)

    # Remove preprocessing header
    subprocess.run(["sed", "/^#/d", "-i", os.path.join(intermediate, "preprocessed.c")])

    # Run conversion to Racket
    rkt_cmd = [
        'racket',
        'src/c-meta.rkt'
    ]
    if function:
        rkt_cmd += ["--function", function]
    rkt_cmd += [intermediate]
    cmd = subprocess.run(rkt_cmd, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
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
    cmd = subprocess.run(["make", "{}-egg".format(os.path.join(build_dir, file_name)), flags], stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    if cmd.returncode:
        cdios_error("CDIOS: Rewriting or backend compilation failed")
        cdios_error(cmd.stdout.decode("utf-8"))
        exit(1)
    elif debug:
        sys.stdout.write(cmd.stdout.decode("utf-8"))

    # Go back to where launched from and copy out result files
    subprocess.run(["cp", "-r", intermediate, cwd])
    os.chdir(cwd)


    if header:
        header_and_namespace(name, intermediate, cdios_success)
    else:
        impl_path = os.path.join(intermediate, "kernel.c")
        with open(impl_path, 'r') as f:
            impl = f.read()
        formatted = clang_format(impl)
        with open(impl_path, 'w') as f:
            impl = f.write(formatted)
        sys.stdout.write(formatted + "\n")



if __name__ == '__main__':
    cdios()
