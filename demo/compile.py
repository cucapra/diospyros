import subprocess
import sys

def compile_tmp():
    # Attempt to run gcc
    cmd = subprocess.run(["gcc", "-S", "tmp.c", "-o", "/dev/null"], stdout=subprocess.PIPE, stderr=subprocess.PIPE)

    # Bail early if GCC fails to compile
    # (note: don't assemble since we might not have a main fn)
    if cmd.returncode:
        sys.stdout.write(cmd.stderr.decode("utf-8"))
        exit(1)

    # Preprocess to handle #defines, etc
    subprocess.run(["gcc", "-E", "tmp.c", "-o", "preprocess-tmp.c"])

    # Remove preprocessing header
    subprocess.run(["sed", "/^#/d", "-i", "preprocess-tmp.c"])

    # Run conversion to Racket
    cmd = subprocess.run(['racket', '../src/c-meta.rkt'], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    if cmd.returncode:
        sys.stdout.write(cmd.stderr.decode("utf-8"))
        exit(1)

    # sys.stdout.write(cmd.stdout.decode("utf-8"))
    subprocess.check_output(["make", "-C", "..", "demo-egg"], stderr=subprocess.STDOUT)
    # subprocess.run(["make", "-C", "..", "demo-egg"], stderr=subprocess.STDOUT)
    subprocess.run(["cat", "../demo-out/kernel.c"])

if __name__ == '__main__':
    compile_tmp()