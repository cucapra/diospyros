import time
import subprocess
import os
import sys
import matplotlib.pyplot as plt
import numpy as np

def plot(files, runtimes, stds):
  print("showing plot")
  x_pos = np.arange(len(files) / 2)
  width = 0.2
  # Build the plot
  fig, ax = plt.subplots()
  bar1 = ax.bar(x_pos - width / 2, runtimes[::2], width, yerr=stds[::2], align='center', alpha=0.5, ecolor='grey', capsize=2, label='test')
  bar2 = ax.bar(x_pos + width / 2, runtimes[1::2], width, yerr=stds[1::2], align='center', alpha=0.5, ecolor='grey', capsize=2, label='orig')
  ax.set_ylabel('Time (s)')
  ax.set_xticks(x_pos)
  ax.set_xticklabels(files[::2], rotation='vertical')
  ax.set_title('Runtimes')
  ax.yaxis.grid(True)
  ax.legend()

  # Save the figure and show
  plt.tight_layout()
  plt.show()
  plt.savefig("fig.png")

N = 10  # num times to test run

def run_test(file):
  print("running " + file)
  # os.popen("make emit-save test=" + file + "; clang test.ll")
  subprocess.run(["make", "emit-save", "test={}".format(file)], check=True)
  r = subprocess.run(["clang", "test.ll"])
  # if r.stderr.readline():
  #   print("bruh")
  test = time_file("./a.out", N)
  subprocess.run(["clang", file])
  orig = time_file("./a.out", N)
  return test, orig

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
  direc = "llvm-tests/"
  for i, filename in enumerate(os.listdir(direc)):
    # if i > 5: break         # test first 5
    try:
      if filename.endswith(".c"):
        rts_test, rts_orig = run_test(direc + filename)
        files += [filename + " test", filename + " orig"]
        runtimes += [np.mean(rts_test), np.mean(rts_orig)]
        stds += [np.std(rts_test), np.std(rts_orig)]
        print(filename + " test: " + str(np.mean(rts_test)))
        print(filename + " orig: " + str(np.mean(rts_orig)))
    except (KeyboardInterrupt, SystemExit):
      sys.exit()
    except:
      pass
  plot(files, runtimes, stds)

if __name__ == "__main__":
  main()