import logging
import sys
import os

from contextlib import contextmanager

OUT_DIR = '_results'
JOBS_FILE = 'jobs.txt'  # The list of job IDs for a batch.


def buildbot_url():
    """Get the base URL for the Buildbot. We have a default, and it can
    be overridden with the `BUILDBOT` environment variable.
    """
    return os.environ.get('BUILDBOT', 'http://cerberus.cs.cornell.edu:5000')


@contextmanager
def chdir(path):
    """Temporarily change the working directory (then change back).
    """
    old_dir = os.getcwd()
    os.chdir(path)
    yield
    os.chdir(old_dir)


def logging_setup():
    # Color for warning and error mesages
    logging.addLevelName(
        logging.WARNING,
        "\033[1;33m%s\033[1;0m" % logging.getLevelName(logging.WARNING))
    logging.addLevelName(
        logging.ERROR,
        "\033[1;31m%s\033[1;0m" % logging.getLevelName(logging.ERROR))

    logging.basicConfig(
        format='%(levelname)s: %(message)s',
        stream=sys.stderr,
        level=logging.INFO)
