import time
import subprocess
import os
import sys
import math
import matplotlib.pyplot as plt
import numpy as np

direc = "llvm-tests/"  # test suite
N = 1000  # num times to test run

def plot(files, runtimes, stds, i):
  print("showing plot")
  x_pos = np.arange(len(files))
  width = 0.3
  # Build the plot
  fig, ax = plt.subplots()
  bar1 = ax.bar(x_pos - width, runtimes[::3], width, yerr=stds[::3], align='center', alpha=0.5, ecolor='grey', capsize=2, label='test')
  bar2 = ax.bar(x_pos, runtimes[1::3], width, yerr=stds[1::3], align='center', alpha=0.5, ecolor='grey', capsize=2, label='orig')
  bar3 = ax.bar(x_pos + width, runtimes[2::3], width, yerr=stds[2::3], align='center', alpha=0.5, ecolor='grey', capsize=2, label='opt')
  ax.set_ylabel('Time (s)')
  ax.set_xticks(x_pos)
  ax.set_xticklabels(files, rotation='vertical')
  ax.set_title('Runtimes')
  ax.yaxis.grid(True)
  ax.legend()

  # Save the figure and show
  plt.tight_layout()
  plt.savefig("fig" + str(i) + ".png")

def run_test(file):
  print("running " + file)
  try:
    subprocess.run(["make", "emit-save", "test={}".format(file)], \
                    check=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    test = time_file("./a.out", N)
    subprocess.run(["clang", "-lm", file])
    orig = time_file("./a.out", N)
    subprocess.run(["clang", "-O2", "-lm", file])
    opt = time_file("./a.out", N)
    return test, orig, opt
  except:
    return None

def time_file(file, n):
  s = []
  for i in range(n):
    start_time = time.time()
    stream = os.popen(file)
    runtime = time.time() - start_time
    # print(stream.read())
    s += [runtime]
  return s

def main():
  files = []
  runtimes = []
  stds = []
  subprocess.run(["cargo", "build"])
  for i, filename in enumerate(os.listdir(direc)):
    if i != 0 and i % 20 == 0: 
      plot(files, runtimes, stds, math.ceil(i / 20))   # test first 7
      files = []
      runtimes = []
      stds = []
    try:
      if filename.endswith(".c"):
        rts = run_test(direc + filename)
        if rts == None:
          print(filename + " failed; skipping")
          continue
        files += [filename]
        runtimes += [np.mean(rts[0]), np.mean(rts[1]), np.mean(rts[2])]
        stds += [np.std(rts[0]), np.std(rts[1]), np.std(rts[2])]
        print(filename + " test: " + str(np.mean(rts[0])))
        print(filename + " orig: " + str(np.mean(rts[1])))
        print(filename + " opt: " + str(np.mean(rts[2])))
    except (KeyboardInterrupt, SystemExit):
      sys.exit()
    except:
      pass
  if i % 20 != 0:
    plot(files, runtimes, stds, math.ceil(i / 20))

if __name__ == "__main__":
  main()