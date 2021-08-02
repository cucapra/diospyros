#! /bin/sh
args=("$@")
FILE=target/debug/libllvmlib.so

if ! [ -f $FILE ]; then
  FILE=target/debug/libllvmlib.dylib
fi

if [[ "$OSTYPE" == "darwin"* ]]; then 
  CLANG=/usr/local/opt/llvm/bin/clang
else
  CLANG=clang
fi 

$CLANG -Xclang -load -Xclang $FILE -emit-llvm -S -o - ${args[0]} | awk '/define/{flag=1; next} /}/{flag=0} flag'