#!/bin/bash
/usr/local/opt/llvm/bin/clang -emit-llvm -S -Xclang -disable-O0-optnone -o build/clang.ll inline-float.c
opt -S -always-inline --inline --mem2reg --scev-aa -simplifycfg --flattencfg --indvars -loops -loop-rotate --loop-simplify --loop-idiom --loop-instsimplify --licm --unroll-threshold=1000000 --loop-unroll --simplifycfg --instcombine --gvn  --mem2reg --dse --adce build/clang.ll -o build/opt.ll
opt -S --cfl-steens-aa build/opt.ll -o build/aa.ll
/usr/local/opt/llvm/bin/clang -emit-llvm -S -Xclang -load -Xclang target/debug/libllvmlib.dylib -mllvm -opt -mllvm -print=false build/aa.ll -o build/diospyros.ll &> err1.txt
opt -S --adce --dse build/diospyros.ll -o build/dce.ll 2> err2.txt \
&& $(CLANG) build/dce.ll -o build/final \
&& build/final
output1=$(grep -c 'Error' err1.txt) 
output2=$(grep -c 'Error' err2.txt)
echo $output1 || $output2