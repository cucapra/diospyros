# Instructions

To build the LLVM pass:

```
  $ mkdir build
  $ cd build
  $ cmake ..
  $ cd ..
  $ make -C build
```

To run the LLVM pass on a C file (`a.c` in our example):

```
  $ clang -Xclang -load -Xclang build/skeleton/libSkeletonPass.* -Xclang -load -Xclang target/debug/libllvm_pass_skeleton.so a.c
```