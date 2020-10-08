import argparse
import sexpdata
import sys
import functools

# Convert specs from our Rosette expressions to ones in our little egg language.

def eprint(*args, **kwargs):
    print(*args, file=sys.stderr, **kwargs)

to_egg_renames = {
    'list' : 'List',
}

def to_value(val, erase):
    [pre, idx] = val.split('$')
    if not erase:
        return "(Get {} {})".format(pre,idx)
    return pre


def to_egg(expr, erase):
    # Literal numbers
    if isinstance(expr, int) or isinstance(expr, float):
        return expr

    # For now, must be a symbolic value
    if not type(expr) is list:
        return to_value(expr._val, erase)

    # Just remove box wrappers
    if expr[0]._val == 'box':
        return to_egg(expr[1], erase)
    # Handle uninterpreted fun app
    if expr[0]._val == 'app':
        return to_egg(expr[1:], erase)

    # Lists and arithmetic operations may be simple renames
    op = ""
    if expr[0]._val in to_egg_renames:
        op = to_egg_renames[(expr[0])._val]

    else:
        op = (expr[0])._val
    children = [to_egg(e, erase) for e in expr[1:]]
    if len(children) < 3 or expr[0]._val == "list":
        return [op] + children
    else:
        # Make variadic things binary for now
        # Fold right over operator
        children_rev = children[::-1]
        expr = functools.reduce(lambda x, y: [op] + [y, x],
            children_rev[1:],
            children_rev[0])
        return expr

    return expr

def preprocess_egg_to_vecs(expr, width):
    if expr[0] != "List":
        print("Cannot preprocess expression")
        return expr

    def elements_to_vec(es):
        if len(es) < width:
            return ["List"] + es
        if len(es) == width:
             # print("vec")
            return ["Vec"] + es
        return ["Concat", ["Vec"] + es[0:width], elements_to_vec(es[width:])]

    return elements_to_vec(expr[1:])

def rosette_to_egg(erase, preprocess, width):
    str_in = sys.stdin.read()
    str_in = str_in.replace("'#&", "")

    sexp = sexpdata.loads(str_in)

    new = to_egg(sexp, erase)
    if preprocess:
        new = preprocess_egg_to_vecs(new, width)
    print(sexpdata.dumps(new, str_as='symbol'))

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('-e', '--erase', action='store_true',
        help="Erase exact expression indices")
    parser.add_argument('-p', '--preprocess', action='store_true',
        help="Preprocess long lists to Vecs")
    parser.add_argument('-w', '--vecwidth', type=int,
        help="Vector width")
    args = parser.parse_args()

    rosette_to_egg(args.erase, args.preprocess, args.vecwidth)

if __name__ == main():
    main()