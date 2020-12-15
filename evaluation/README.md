# Diospyros Evaluation

This directory contains the evaluation scripts for our ASPLOS 2021 paper,
"Vectorization for Digital Signal Processors via Equality Saturation".


This artifact is intended to reproduce the 4 main experimental results from the
paper:
- **Compiling benchmarks (Table 1; Figure 4)** Compilation and simulated
cycle-level performance of 21 kernels (across 4 distinct functions). We compare
kernels compiled by Diospyros with kernels compiled with the vendor's optimizing
compiler and optimized library functions.
- **Translation validation (Section 3)**  Translation validation
for all kernels that the scalar specification and vectorized result (both in
our imperative vector domain specific language) are equivalent.
- **Timeout ablation study (Figure 5)** Ablation study on a single kernel
(10×10 by 10×10 `MatMul`) over a range of equality saturation timeouts.
- **Application case study (Section 5.6)** Speedup of an open source
computer vision application (the [Theia][] structure-from-motion library) with a single
kernel compiled by Diospyros (QR decomposition).

We have split this artifact into two components:
1. **Diospyros compiler.** This is our publicly available compiler that
  produces C/C++ code with intrinsics. This component can be run on the provided
  [VirtualBox][] virtual machine, or installed from source and run locally on the
  reviewer's machine.
2. **Evaluation on licensed instruction set simulator (ISS).**
  Our compiler targets the Tensilica Fusion G3, which does not have an
  publicly accessible compiler or ISS (the vendor provides free academic licenses,
  but the process is not automated). To reproduce the cycle-level simulation
  statistics from our paper, we have provided reviews limited access to our
  research server (with permission from the AEC chairs).
  
We estimate the required components of this artifact to take around 2 hours of reviewer time. To run one optional memory intensive kernel takes an additional 4.5 hours; and inspecting additional elements or writing new kernels will take a variable amount of time.

[virtualbox]: https://www.virtualbox.org/
[theia]: https://github.com/sweeneychris/TheiaSfM

----

## Prerequisites

### Option 1: VirtualBox
If you use the provided VirtualBox virtual machine, it has all dependencies pre-installed.

1. Using [VirtualBox][], open the provided OVA file and follow the instructions to import and start the VM. Then log in with:

```
password: asplos
```
2. Right-click the Desktop and select "Open in Terminal".
3. Go to the project directory:
```
cd diospyros
```

We also recommend opening [this README][here] on the VM so you can easily copy and paste Terminal commands; open Firefox and this page can be found on the bookmarks bar.

[here]: https://github.com/cucapra/diospyros/blob/master/evaluation/README.md

### Option 2: Running locally
To run locally, clone this repository and follow the instructions for installing prerequisites from the top-level README.

```
cd diospyos
```

## Using the compiler in the VirtualBox or locally

First, run make to ensure the compiler is up-to-date:

#### Time estimate: 1 minute
```
make
```

----

### Generating C/C++ with Intrinsics (on the VM or locally)

To start, we will generate most of the compiled C/C++ with intrinsics independently from the research server (either on the provided VM or locally). To skip running on the licensed simulator, we pass the `--skiprun` flag to the following commands.

First, to sanity-check the setup, run the following test command, which compiles the smallest size of each unique kernel with a 10 second timeout for each:

#### Time estimate: 30 seconds
```
python3 evaluation/eval_benchmarks.py --timeout 10 --skiprun --test -o test-results
```

This produces `*.c` files with vector intrinsics, along with metadata used for downstream translation validation, in a new `test-results` directory. The directory is structured with subdirectories for each function and size:
```
- test-results
    - 2d-conv
        - <sizes>
    - mat-mul
        - <sizes>
    - q-prod
        - <sizes>
    - qr-decomp
        - <sizes>
```
Within each size, there are the following files:
```
- egg-kernel.c.            : vectorized C code with intrinsics.
- params.json              : input size and vectorization parameters.
- spec.rkt                 : specification lifted with symbolic evaluation, in DSL.
- res.rkt                  : vectorized result of equality saturation, in DSL.
- outputs.rkt, prelude.rkt : metadata for downstreaam translation validation.
- stats.json               : summary statistics from compilation, including wall clock time and memory usage.
```

Once that succeeds, we can run the benchmarks with the default 180 second timeout.  For now,
we suggest skipping the one kernel (`4x4 QRDecomp`) that requires 38 GB of memory (as documented in Table 1), since it is infeasible to run in a VM. If you are running locally on a machine with sufficient memory, you can include this benchmark by omitting the `--skiplargemem` flag.

#### Time estimate: 45 minutes (+5 hours if no `--skiplargemem`)
```
python3 evaluation/eval_benchmarks.py --skiprun --skiplargemem -o results
```

The results here follow the same pattern of files as specified above, but for 20/21 total kernel sizes.

### Translation validation

To run translation validation on the results we just generated, we will rerun the same script and pass `--validation` and the `--skipsynth` flag to tell the script to not regenerate the results.

#### Time estimate: 1 minute
```
python3 evaluation/eval_benchmarks.py --skiprun --skipsynth --validation -o results
```

The line `Translation validation successful! <N> elements equal` will be printed to the Terminal in green for each kernel that passes.

----

## Running code on the licensed Instruction Set Simulator (on the research server)

### Setting up your directory

First, SSH into our research server using the provided credentials (note, it may be easier to SSH in from your local machine's Terminal instead of opening a new Terminal window in the VM; either should work):

#### On the VM/locally
Open a new Terminal and run:
```
ssh <user>@<server address>
```

On the research server, cd to the project directory:

#### On the server
```
cd /data/asplos-aec
```

Here, we want to create a new folder per reviewer to avoid overwriting each other's work. Run the following, replacing `<letter>` with the reviewer letter you are assigned in HotCRP (for example, `mkdir reviewer-A`). Then, copy the `diospyros` repository into your new directory and `cd` there:

#### On the server
```
mkdir reviewer-<letter>
cp -r diospyros reviewer-<letter>/diospyros
cd reviewer-<letter>/diospyros
```

Now, back on your original machine (the VM or locally), run the following command to copy the data you just generated to your new directory on the research server (replacing `<letter>` with your letter):

#### On the VM/locally, in the `diospryros` root directory (Time estimate: 1 minute)
```
scp -r results <user>@<server address>:/data/asplos-aec/reviewer-<letter>/diospyros/results
```

Back on the server, check that you have your results:

#### On the server
```
ls results/*
```

You should see the 4 kernel directories and respective sizes:
```
2d-conv    mat-mul    q-prod    qr-decomp
```


### (Optional) Running the memory-intensive kernel

As described in the second paragraph of **5.3. Kernel Benchmarks**, the  `4x4 QRDecomp` kernel is a pathological case where equality saturation takes 38GB of memory and ultimately, the E-graph does not saturate and it finds no vector instructions. We included this case in our paper to show where this approach still needs improvement, and to show that we can still beat library performance.

Because of the very high memory usage, this kernel takes approximately 4.5 hours to fully compile (even with a 3 minute timeout on equality saturation; the backend of our compiler is time-intensive on the input file, which is itself 500 MB of source). We thus leave recompiling this kernel as optional.

If you would like to skip compiling this kernel, you can copy the (unsuccessfully-vectorized, but otherwise compiled with our backend kernel) from elsewhere on our server:

#### Option 1: use existing data
```
cp -r ../../diospyros-asplos-aec/qr-decomp/4_4r results/qr-decomp/
```

#### Option 2: Generate new data (Time estimate: 4.5 hours) (Optional)

If you are okay waiting, this command will regenerate the data for this kernel (passing the `--onlylargemem` flag to generate just the one kernel left):

```
python3 evaluation/eval_benchmarks.py --skiprun --onlylargemem -o results
```

### Running the Instruction Set Simulator

Now, we can actually run the generated kernels on the vendor's instruction set simulator. We pass the `--skipsynth` flag to avoid re-running synthesis and compilation to C with intrinsics. We also pass in the pre-built expert binary for matrix multiply.

#### Time estimate: 20 minutes
```
python3 evaluation/eval_benchmarks.py --skipsynth -o results --matmulexpert /data/asplos-aec/diospyros-asplos-aec/mat_mul_expert.o
```

This will add a file `egg-kernel.csv` to each subdirectory of `results` with cycle-level performance for each kernel and corresponding baseline.

### Seeing the Results

Now that we have collected the data, the next step is to analyze the results to draw the charts and tables you see in the ASPLOS paper.
First, use `chart_benchmarks.py` to generate the plots:

    python3 evaluation/chart_benchmarks.py -d results

This produces the following files:
```
all_benchmarks.csv          : Combined all individual benchmark runs into one CSV (Feeds Table 1)
all_bechmarks_chart.pdf     : Charting graph for all benchmarks (Figure 4)
extended_abstract_chart.pdf : Charting small graph for extended abstract
```

The produced `all_benchmarks.csv` file contains all the raw data that went into the plots.
You can look at it directly if you're curious about specific numbers.
To see some statistics about the compilation process, run the `benchtbl.py` script:

    python3 evaluation/benchtbl.py --plain

This script reads `all_benchmarks.csv` to make a table like Table 1 in the ASPLOS paper.
The `--plain` flag emits a plain-text table for reading directly; omit this flag to generate a LaTeX fragment instead.

#### Optional: copy data back to VM/local machine

You might prefer to view the PDF charts locally; if so, copy them back to your machine with:

#### On the VM/locally
```
scp -r <user>@<server address>:/data/asplos-aec/reviewer-<letter>/diospyros/*.pdf .
```

----

### Theia Case Study

The ASPLOS paper puts the QR decomposition kernel into context by measuring the impact on performance in an application: the [Theia][] structure-from-motion library.
The `theia` subdirectory in this evaluation package contains the code necessary to reproduce those end-to-end results.

The first step is to get the generated C code for the QR decomposition kernel.
Copy the `egg_kernel.c` file from our previously generated code for an `N=3` `vecwidth=4` `QRDecomp` to the Theia directory:
```
cp results/qr-decomp/3_4r/egg-kernel.c theia/egg-kernel.c
```

**Time estimate: 1 minute.**

Then, type `make run -C evaluation/theia` to compile and execute both versions of the `DecomposeProjectionMatrix` function: one using Eigen (as the original open-source code does) and one using the Diospyros-generated QR kernel.
You can visually check the outputs to make sure they match.

**Time estimate: 10 seconds.**

To post-process this output into the final numbers you see in the paper, pipe it into the `dpmresults.py` analysis script:

    make run -C evaluation/theia | python3 evaluation/theia/dpmresults.py

This will produce a JSON document with three values: the cycle count for the Eigen- and Diospyros-based executions, and the speedup (which is just the ratio of the two cycle counts).
You can see the cycle counts and speedup number in the ASPLOS paper at the end of Section 5.6.

---

### Timeout Ablation Study

Our ASPLOS paper studies the effect of changing the timeout of the equality
saturation solver on the quality of the generated solution.
The ablation study varies the timeout given to our solver and reports the
number of cycles taken by the design.
We assume that this experiment is performed on our research server with the
Xtensa compiler and simulator available.

The process of reproducing has two steps:
1. Run the study with different timeouts and generate executable code.
2. Simulate the executable code with the simulator.

The script `evaluation/ablation/ablation-exp-gen.py` can be used to generate
executable vectorized solutions:

#### Time estimate: 24 minutes
```
python3 evaluation/ablation/ablation-exp-gen.py -p evaluation/ablation/params/mat-mul-large -o exp-out -t 10 30 60 120 180
```

- `-p`: Specifies the parameter file, which itself describes the size of
  matrices used in a matrix-multiply kernel.
- `-o`: Location of the output folder
- `-t`: A list of the timeouts to run the solver with.

Once the script is finished running, run the following to collect the data:

#### Time estimate: 4 minutes
```
cd exp-out
A_ROWS=10 A_COLS=10 B_ROWS=10 B_COLS=10 ./run_all.sh
cd -
```

This will generate `exp-out/ablation.csv`

Finally, run the following to generate the ablation study chart:
```
python3 evaluation/ablation/ablation_chart.py exp-out/ablation.csv
```
This will generate `ablation.pdf`.


#### Optional: copy data back to VM/local machine

Again, if you prefer to view PDF charts locally; if so, copy this back to your machine with:

#### On the VM/locally
```
scp -r <user>@<server address>:/data/asplos-aec/reviewer-<letter>/diospyros/ablation.pdf .
```

## Optional: writing new rewrite rules

Our rewrite rules are defined in `src/dios-egraphs-src/rules.rs` using the [egg: egraphs good][egg] Rust library. Try adding a new rule and repeating some of the previous steps. For example, we can write a new rule that says anything divided by 0 is 0:
```
rw!("div-new"; "(/ ?a 0)" => "0"),
```

For more extensive rule patterns, refer to the [egg documentation][egg]. You can also try adding new operations to use in your rules by editing `src/dios-egraphs-src/veclang.rs`. 

[egg]: https://docs.rs/egg/0.6.0/egg/index.html

