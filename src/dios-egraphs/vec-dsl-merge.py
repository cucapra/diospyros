#!/usr/bin/env python3
import argparse
import sys
import sexpdata
import glob


def merge_all(progs):
    """
    Returns a single program by `Concat`ing progs.

    @returns a vec-dsl program.
    """
    cur_prog = []
    progs.reverse()
    for prog in progs:
        if cur_prog == []:
            cur_prog = prog
        else:
            cur_prog = [sexpdata.Symbol("Concat"), prog, cur_prog]

    return cur_prog


def all_files(prefix, filenames):
    """
    Transform a list of file names into a list of programs. Expects
    the files to have names in the form `<name>-<n>` where `n` is the
    position of the program chunk contained in the file.
    """
    progs = [i for i in range(len(filenames))]
    for file in filenames:
        # Remove the prefix from the file
        idx = int(file[len(prefix):])
        with open(file, 'r') as f:
            prog = sexpdata.load(f)
            progs[idx] = prog

    return progs


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('-p', '--prefix', required=True,
                        type=str, help='The prefix in the names of files')
    parser.add_argument('files', nargs='+',
                        help="Paths to input programs")
    args = parser.parse_args()
    progs = all_files(args.prefix, args.files)
    print(sexpdata.dumps(merge_all(progs)))
