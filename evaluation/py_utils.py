import os

results_dir = "../diospyros-private/results/"
harness_dir = "evaluation/"

conv2d = "2d-conv"
matmul = "mat-mul"
qrdecomp = "qr-decomp"
qprod = "q-prod"

benchmarks = [
    matmul,
    conv2d,
    qrdecomp,
    qprod
]

def make_dir(d):
    """Makes a directory if it does not already exist"""
    if not os.path.exists(d):
        os.mkdir(d)

def listdir(d):
    """Lists the full paths of the contents of a directory"""
    return [os.path.join(d, f) for f in os.listdir(d)]
