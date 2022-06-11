import time
import subprocess
import os
import sys
import math
import matplotlib.pyplot as plt
import numpy as np

def plot(files, runtimes, stds, i, command):
  # Build the plot
  x_pos = np.arange(len(files))
  width = 0.3
  fig, ax = plt.subplots()
  bar1 = ax.bar(x_pos - width, runtimes[::3], width, yerr=stds[::3], align='center', alpha=0.5, ecolor='grey', capsize=2, label='llvm-pass')
  bar2 = ax.bar(x_pos, runtimes[1::3], width, yerr=stds[1::3], align='center', alpha=0.5, ecolor='grey', capsize=2, label='no-opt')
  bar3 = ax.bar(x_pos + width, runtimes[2::3], width, yerr=stds[2::3], align='center', alpha=0.5, ecolor='grey', capsize=2, label='O2-opt')
  ax.set_ylabel('Time (s)')
  ax.set_xticks(x_pos)
  ax.set_xticklabels(files, rotation='vertical')
  ax.set_title('Runtimes')
  ax.yaxis.grid(True)
  ax.legend()

  plt.tight_layout()
  if not os.path.exists('runtimes'):
    os.makedirs('runtimes')
  plt.savefig("runtimes/" + command + str(i) + ".png")

def run_test(file, command, N):
  # Run the given file N number of times, using three different compilation methods
  print("running " + file + " " + str(N) + " times...")
  try:
    subprocess.run(["make", command, "test={}".format(file)], \
                    check=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    test = time_file("./a.out", N)
    subprocess.run(["clang", "-I", "polybench-tests/utilities", "polybench-tests/utilities/polybench.c", "-lm", file])
    orig = time_file("./a.out", N)
    subprocess.run(["clang", "-I", "polybench-tests/utilities", "polybench-tests/utilities/polybench.c", "-O2", "-lm", file])
    opt = time_file("./a.out", N)
    return test, orig, opt
  except:
    return None

def time_file(file, N):
  # Measure the time it takes to run a given file N times.
  s = []
  for i in range(N):
    # print("run #" + str(i))
    start_time = time.time()
    stream = os.popen(file)
    runtime = time.time() - start_time
    # print(stream.read())
    s += [runtime]
  return s

def iter_direc(direc, command, N):
  # Iterate through the given directory -- intended for the c-tests/ suite.
  files = []
  runtimes = []
  stds = []
  failed = []
  for i, filename in enumerate(os.listdir(direc)):
    if i != 0 and i % 20 == 0: 
      plot(files, runtimes, stds, math.ceil(i / 20), command)   
      files = []
      runtimes = []
      stds = []
    try:
      if filename.endswith(".c"):
        rts = run_test(direc + filename, command, N)
        if rts == None:
          print(filename + " failed; skipping")
          failed.append(filename)
          continue
        files += [filename]
        runtimes += [np.mean(rts[0]), np.mean(rts[1]), np.mean(rts[2])]
        stds += [np.std(rts[0]), np.std(rts[1]), np.std(rts[2])]
        # print(filename + " test: " + str(np.mean(rts[0])))
        # print(filename + " orig: " + str(np.mean(rts[1])))
        # print(filename + " opt: " + str(np.mean(rts[2])))
    except (KeyboardInterrupt, SystemExit):
      sys.exit()
    except:
      pass
  if i % 20 != 0:
    plot(files, runtimes, stds, math.ceil(i / 20), command)
  return failed

def iter_poly(direc, command, N):
  # Iterate through the given _nested_ directory -- intended for the polybench-tests/ suite.
  files = []
  runtimes = []
  stds = []
  failed = []
  counter = 1
  for dir1 in os.listdir(direc):
    d = direc + dir1 + "/"
    for filename in os.listdir(d):
      if len(files) >= 10: 
        plot(files, runtimes, stds, counter, command)   # plot 10 at a time
        files = []
        runtimes = []
        stds = []
        counter += 1
      try:
        if filename.endswith(".c"):
          rts = run_test(d + filename, command, N)
          if rts == None:
            print(filename + " failed; skipping")
            failed.append(filename)
            continue
          files += [filename]
          runtimes += [np.mean(rts[0]), np.mean(rts[1]), np.mean(rts[2])]
          stds += [np.std(rts[0]), np.std(rts[1]), np.std(rts[2])]
          # print(filename + " llvm: " + str(np.mean(rts[0])))
          # print(filename + " orig: " + str(np.mean(rts[1])))
          # print(filename + " o2: " + str(np.mean(rts[2])))
      except (KeyboardInterrupt, SystemExit):
        sys.exit()
      except:
        pass
  if len(files) > 0:
    plot(files, runtimes, stds, counter, command)
  return failed

def main():
  subprocess.run(["cargo", "build"])
  print(sys.argv[1])
  if sys.argv == []:
    print("Please indicate test suite.")
    sys.exit()
    
  direc = sys.argv[1] + "/"
  if direc == "polybench-tests":
    # POLYBENCH TEST SUITE (nested)
    direc = "polybench-tests/linear-algebra/kernels/"
    command = "run-polybench"
    N = 20
    failed = iter_poly(direc, command, N)
  else:
    # C TEST SUITE (not nested)
    command = "run-opt"
    N = 100
    failed = iter_direc(direc, command, N)
  print("check runtimes/ for plots.")
  if not failed == []:
    print("failed tests:")
    print(*failed, sep = ", ") 

if __name__ == "__main__":
  main()