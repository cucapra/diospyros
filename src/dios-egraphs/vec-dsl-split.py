#!/usr/bin/env python3
import common
import sexpdata
import pprint
import sys
import logging
import argparse

sys.path.append('.')


def split(prog):
    """
    Split a given program if the top-level is a Concat. If the top-level
    is not a Concat, returns the program.

    @returns a list of programs under the concat in the same order as the
    concat.
    """
    if prog[0]._val == 'Concat':
        return [prog[1], prog[2]]
    else:
        return [prog]


def split_into(prog, parts_num):
    """
    Tries to split the program into `parts_num` splits or up till when there are
    no more splits possible.

    Given a Concat(A, B), the script ASSUMES that A is itself not a concat
    and tried to only split B. Generates a warning if A is actually a concat.
    """
    parts = [prog]

    while(True):
        # Split the program in the back
        to_split = parts.pop()
        splits = split(to_split)
        if len(splits) == 1:
            parts.append(splits[0])
            break
        else:
            # Warn if we violate assumptions
            if splits[0][0]._val == 'Concat':
                logging.warning(
                    'First part of a split is a Concat. This violates splitting assumptions')

            parts += splits

        if len(parts) >= parts_num:
            break

    return parts


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('-n', '--num-parts', type=int, required=True,
                        help="Max number of parts to split this program into.")
    parser.add_argument('-p', '--prefix', type=str, required=True,
                        help="Prefix for the files to be saved")
    args = parser.parse_args()
    str_in = sys.stdin.read()
    prog = sexpdata.loads(str_in)

    all_splits = split_into(prog, args.num_parts)
    print(f'Created {len(all_splits)} splits from program.')
    for (idx, part) in enumerate(all_splits):
        # Save parts into files named prefix-idx
        with open(f'{args.prefix}-{idx}', 'w') as f:
            f.write(sexpdata.dumps(part))


if __name__ == '__main__':
    common.logging_setup()
    main()
