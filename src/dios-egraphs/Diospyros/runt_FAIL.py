import click
import subprocess
import sys

# I'd like for this to be able to detect if there is an "error" in a file
# e.g. an assertion error
# I'd like to grep for an error strings, and then report if the test passed or failed.


@click.command()
@click.argument('test_file',
                type=click.Path(exists=True),
                metavar='<test_file>')
def run(test_file):
    test_path = [f"test={test_file}"]
    cmd = subprocess.run(["make", "run-opt"] + test_path,
                         stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    sys.stdout.write(cmd.stdout.decode('utf-8'))


if __name__ == "__main__":
    run()
