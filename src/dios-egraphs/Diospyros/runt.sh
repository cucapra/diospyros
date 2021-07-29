#! /bin/sh
args=("$@")
FILE=target/debug/libllvmlib.so
if [ -f $FILE ]; then
  clang -Xclang -load -Xclang $FILE -emit-llvm -S -o - ${args[0]}    # .so file
else
  clang -Xclang -load -Xclang target/debug/libllvmlib.dylib -emit-llvm -S -o - ${args[0]}    # .dylib file
fi