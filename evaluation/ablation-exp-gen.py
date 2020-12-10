import argparse
import os
import sys
import subprocess
import shutil

from py_utils import make_dir, listdir

# Name of the directory to store the result of running example-gen.rkt
BASE = "base"

def check_path(path, diagnostic):
    """
    Make sure that `path` exists and exits otherwise.
    """
    if not os.path.exists(path):
        print(f"Could not find {path}. {diagnostic}")
        sys.exit(1)

def generate_base(params, out):
    """
    Generate a folder out/BASE with the required spec for the experiment.
    """

    make_dir(out)
    experiment_path = os.path.join(out, BASE)

    print(f"Generating {out}/{BASE}")
    subprocess.run([
        "racket",
        "src/example-gen.rkt",
        "-b", "mat-mul",
        "-p", params,
        "-o", experiment_path
    ],
    stderr=subprocess.PIPE)

    # Add all required file for the harness.
    for file in listdir("evaluation/mat-mul"):
        shutil.copy(file, experiment_path)



def run_experiment(timeout, out):
    """
    Invoke the rewriter on the spec file and save the result of the rewrite into
    out/timeout/res.rkt
    """

    # My programming has the best defenses.
    spec_path = os.path.join(out, BASE, "spec.rkt")
    check_path(
        spec_path,
        f"The script should automatically generate this file. Something went wrong in the last step.")

    # Make the directory with this file
    exp_dir = os.path.join(out, str(timeout))
    shutil.copytree(os.path.join(out, BASE), exp_dir)

    result = os.path.join(exp_dir, "res.rkt")
    with open(result, 'w+') as f:
        print(f"Running rewriter with timeout={timeout}")
        subprocess.run([
            "cargo",
            "run",
            "--manifest-path", "src/dios-egraphs/Cargo.toml",
            spec_path
        ],
        env=dict(os.environ, TIMEOUT=str(timeout)),
        stderr=subprocess.PIPE,
        stdout=f)

    cxx_out = os.path.join(exp_dir, "kernel.c")
    with open(cxx_out, 'w+') as f:
        print(f"Compiling {result} to C++")
        subprocess.run([
            "racket",
            "src/main.rkt",
            "-e",
            exp_dir
        ],
        env=dict(os.environ, TIMEOUT=str(timeout)),
        stderr=subprocess.PIPE,
        stdout=f)


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('-t', '--timeouts', nargs='+', help='Timeouts to run the ablation study', required=True)
    parser.add_argument('-p', '--parameter', help='Location of the parameters file', required=True)
    parser.add_argument('-o', '--output-dir', help='Location of the output directory', required=True)
    args = parser.parse_args()

    # Make sure that compiler is built and expected scripts exist.
    paths = [
        "src/dios-egraphs/Cargo.toml",
        "src/example-gen.rkt",
        "evaluation/mat-mul/harness.c",
        "evaluation/mat-mul/Makefile",
    ]
    for path in paths:
        check_path(path, "Are you running the script from the repository root?")

    # Don't overwrite the output directory
    if os.path.exists(args.output_dir):
        print(f'{args.output_dir} already exists. Refusing to overwrite it.')
        sys.exit(1)

    generate_base(args.parameter, args.output_dir)
    for timeout in args.timeouts:
        run_experiment(timeout, args.output_dir)
