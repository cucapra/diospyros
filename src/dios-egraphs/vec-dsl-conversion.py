import argparse
import sexpdata
import sys

# Convert specs from our Rosette expressions to ones in our little egg language.

to_egg_renames = {
    'list' : 'List',
    'bvadd' : '+',
    'bvmul' : '*',
}

def idx_from_str(s):
    return int(s.split('$')[-1])

# For now, assume 2 inputs of equal size, 1/2 max [highest idx] + 1
def max_symbolic_idx(expr):
    # For now, must be a symbolic value
    if not type(expr) is list:
        return idx_from_str(expr._val)
    if expr[0]._val in to_egg_renames:
        return max([max_symbolic_idx(e) for e in expr[1:]])
    if expr[0]._val == 'box':
        return max_symbolic_idx(expr[1])

    print("skipping: ", expr)
    return expr

def to_value(val, max_idx, erase):
    idx = idx_from_str(val)
    v = ''
    if idx < (max_idx + 1)/2:
        v += 'A'
    else:
        v += 'B'
    if not erase:
        v = "(Get {} {})".format(v,str(idx))
    return v


def to_egg(expr, max_idx, erase):
    # For now, must be a symbolic value
    if not type(expr) is list:
        return to_value(expr._val, max_idx, erase)
    # Lists and arithmetic operations are simple renames
    if expr[0]._val in to_egg_renames:
        rename = to_egg_renames[(expr[0])._val]
        return [rename] + [to_egg(e, max_idx, erase) for e in expr[1:]]
    # Just remove box wrappers
    if expr[0]._val == 'box':
        return to_egg(expr[1], max_idx, erase)

    print("skipping: ", expr)
    return expr

def preprocess_egg_to_vecs(expr):
    if expr[0] != "List":
        print("Cannot preprocess expression")
        return expr

    def elements_to_vec(es):
        if len(es) < 4:
            return ["List"] + es
        if len(es) == 4:
            return ["Vec4"] + es
        return ["Concat", ["Vec4"] + es[0:4], elements_to_vec(es[4:])]

    return elements_to_vec(expr[1:])

def rosette_to_egg(erase, preprocess):
    sexp = sexpdata.load(sys.stdin)

    max_idx = max_symbolic_idx(sexp)
    new = to_egg(sexp, max_idx, erase)
    if preprocess:
        new = preprocess_egg_to_vecs(new)
    print(sexpdata.dumps(new, str_as='symbol'))

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('-e', '--erase', action='store_true',
        help="Erase exact expression indices")
    parser.add_argument('-p', '--preprocess', action='store_true',
        help="Preprocess long lists to Vec4s")
    args = parser.parse_args()

    rosette_to_egg(args.erase, args.preprocess)

if __name__ == main():
    main()