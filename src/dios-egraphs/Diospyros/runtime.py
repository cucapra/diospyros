import time
import subprocess
import os
import sys
import matplotlib.pyplot as plt
import numpy as np

def plot(files, runtimes):
  print("show plot")
  print(files, runtimes)
  fig = plt.figure()
  ax = fig.add_axes([0,0,1,1])
  ax.bar(files,runtimes)
  plt.ion()
  plt.show()

N = 1

def run_test(file):
  print("running " + file)
  # os.popen("make emit-save test=" + file + "; clang test.ll")
  subprocess.run(["make", "emit-save", "test={}".format(file)], check=True)
  subprocess.run(["clang", "test.ll"])
  s = 0
  for i in range(N):
    start_time = time.time()
    stream = os.popen("./a.out")
    runtime = time.time() - start_time
    print(stream.read())
    s += runtime
  return s / N

def main():
  files = []
  runtimes = []
  subprocess.run(["cargo", "build"])
  for filename in os.listdir("llvm-tests"):
    try:
      if filename.endswith(".c"):
        rt = run_test("llvm-tests/" + filename)
        files += [filename]
        runtimes += [rt]
        print(filename + " avg runtime: " + str(rt))
    except (KeyboardInterrupt, SystemExit):
      sys.exit()
  plot(files, runtimes)

if __name__ == "__main__":
  main()