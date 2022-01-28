FILE=target/debug/libllvmlib.so

if ! [ -f $FILE ]; then
  FILE=target/debug/libllvmlib.dylib
fi

if [[ "$OSTYPE" == "darwin"* ]]; then 
  CLANG=/usr/local/opt/llvm/bin/clang
else
  CLANG=clang
fi 

TEST=./llvm-tests/add.c

$CLANG -emit-llvm -S -Xclang -disable-O0-optnone $TEST \
| opt -S -always-inline --inline --mem2reg --scev-aa -simplifycfg --flattencfg --indvars -loops -loop-rotate --loop-simplify --loop-idiom --loop-instsimplify --licm --unroll-threshold=1000000 --loop-unroll --simplifycfg --instcombine --gvn  --mem2reg --dse --adce -o build/sample -
