#! /bin/sh
args=("$@")
FILE=target/debug/libllvmlib.so
if [[ "$OSTYPE" == "darwin"* ]]; then 
  CLANG=/usr/local/opt/llvm/bin/clang
else
  CLANG=clang
fi 

if [ -f $FILE ]; then
  $CLANG -Xclang -load -Xclang $FILE -emit-llvm -S -o - ${args[0]}    # .so file
else
  $CLANG -Xclang -load -Xclang target/debug/libllvmlib.dylib -emit-llvm -S -o - ${args[0]}    # .dylib file
fi