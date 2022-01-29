import click
import subprocess
import sys


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
