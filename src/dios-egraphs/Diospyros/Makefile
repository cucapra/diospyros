ifeq ($(shell uname),Darwin)
    EXT := dylib
	CLANG := /usr/local/opt/llvm/bin/clang
	SETUP := bash set_up_mac.sh
		LIB := src/lib.rs Cargo.toml .cargo/config
else
    EXT := so
	CLANG = clang
	SETUP := :
		LIB := src/lib.rs Cargo.toml
endif

.PHONY: target/debug/libllvmlib.$(EXT)

run: set-up-mac target/debug/libllvmlib.$(EXT) diospyros.cpp 
	$(CLANG) -Xclang -load -Xclang target/debug/libllvmlib.$(EXT) $(test)

run-o2: set-up-mac target/debug/libllvmlib.$(EXT) diospyros.cpp 
	$(CLANG) -O2 -Xclang -load -Xclang target/debug/libllvmlib.$(EXT) $(test)

run-out: set-up-mac target/debug/libllvmlib.$(EXT) diospyros.cpp 
	$(CLANG) -Xclang -load -Xclang target/debug/libllvmlib.$(EXT) $(test)
	./a.out

run-out-o2: set-up-mac target/debug/libllvmlib.$(EXT) diospyros.cpp 
	$(CLANG) -O2 -Xclang -load -Xclang target/debug/libllvmlib.$(EXT) $(test)
	./a.out

run-all: set-up-mac target/debug/libllvmlib.$(EXT) diospyros.cpp 
	bash run_all.sh

emit: set-up-mac target/debug/libllvmlib.$(EXT) diospyros.cpp 
	$(CLANG) -Xclang -load -Xclang target/debug/libllvmlib.$(EXT) -emit-llvm -S -o - $(test)

emit-o2: set-up-mac target/debug/libllvmlib.$(EXT) diospyros.cpp 
	$(CLANG) -O2 -Xclang -load -Xclang target/debug/libllvmlib.$(EXT) -emit-llvm -S -o - $(test)

test-opt: set-up-mac target/debug/libllvmlib.$(EXT) diospyros.cpp 
	$(CLANG) -emit-llvm -S -Xclang -disable-O0-optnone -o clang.ll $(test)
	opt -S --inline --mem2reg --indvars --loop-simplify --loop-instsimplify --licm --loop-unroll --simplifycfg clang.ll -o opt.ll
	$(CLANG) -emit-llvm -S -Xclang -load -Xclang target/debug/libllvmlib.$(EXT) opt.ll -o finish.ll
	opt -S --adce finish.ll -o final.ll

min-opt: set-up-mac target/debug/libllvmlib.$(EXT) diospyros.cpp 
	$(CLANG) -emit-llvm -S -Xclang -disable-O0-optnone -o build/clang.ll $(test)
	opt -S -always-inline --inline --mem2reg --scev-aa --unroll-threshold=1000000 --loop-unroll --simplifycfg --mem2reg --dse --adce build/clang.ll -o build/opt.ll
	opt -S --cfl-steens-aa build/opt.ll -o build/aa.ll
	$(CLANG) -emit-llvm -S -Xclang -load -Xclang target/debug/libllvmlib.$(EXT) -mllvm -opt -mllvm -print=false build/aa.ll -o build/diospyros.ll
	opt -S --adce --dse build/diospyros.ll -o build/dce.ll
	$(CLANG) build/dce.ll -o build/final
	build/final

run-opt: set-up-mac target/debug/libllvmlib.$(EXT) diospyros.cpp 
	$(CLANG) -emit-llvm -S -Xclang -disable-O0-optnone -o build/clang.ll $(test)
	opt -S -always-inline --inline --mem2reg --scev-aa -simplifycfg --flattencfg --indvars -loops -loop-rotate --loop-simplify --loop-idiom --loop-instsimplify --licm --unroll-threshold=1000000 --loop-unroll --simplifycfg --instcombine --gvn  --mem2reg --dse --adce build/clang.ll -o build/opt.ll
	opt -S --cfl-steens-aa build/opt.ll -o build/aa.ll
	$(CLANG) -emit-llvm -S -Xclang -load -Xclang target/debug/libllvmlib.$(EXT) -mllvm -opt -mllvm -print=false build/aa.ll -o build/diospyros.ll
	opt -S --adce --dse build/diospyros.ll -o build/dce.ll
	$(CLANG) build/dce.ll -o build/final
	build/final

print-opt: set-up-mac target/debug/libllvmlib.$(EXT) diospyros.cpp 
	$(CLANG) -emit-llvm -S -Xclang -disable-O0-optnone -o build/clang.ll $(test)
	opt -S -always-inline --inline --mem2reg --scev-aa -simplifycfg --flattencfg --indvars -loops -loop-rotate --loop-simplify --loop-idiom --loop-instsimplify --licm --unroll-threshold=1000000 --loop-unroll --simplifycfg --instcombine --gvn  --mem2reg --dse --adce build/clang.ll -o build/opt.ll
	opt -S --cfl-steens-aa build/opt.ll -o build/aa.ll
	$(CLANG) -emit-llvm -S -Xclang -load -Xclang target/debug/libllvmlib.$(EXT) -mllvm -opt -mllvm -print=true build/aa.ll -o build/diospyros.ll
	opt -S --adce --dse build/diospyros.ll -o build/dce.ll
	$(CLANG) build/dce.ll -o build/final
	build/final

no-opt: set-up-mac target/debug/libllvmlib.$(EXT) diospyros.cpp 
	$(CLANG) -emit-llvm -S -Xclang -disable-O0-optnone -o build/clang.ll $(test)
	opt -S -always-inline --inline --mem2reg --scev-aa -simplifycfg --flattencfg --indvars -loops -loop-rotate --loop-simplify --loop-idiom --loop-instsimplify --licm --unroll-threshold=1000000 --loop-unroll --simplifycfg --instcombine --gvn  --mem2reg --dse --adce build/clang.ll -o build/opt.ll
	opt -S --cfl-steens-aa build/opt.ll -o build/aa.ll
	$(CLANG) -emit-llvm -S -Xclang -load -Xclang target/debug/libllvmlib.$(EXT) -mllvm -opt=false -mllvm -print=false build/aa.ll -o build/diospyros.ll
	opt -S --adce --dse build/diospyros.ll -o build/dce.ll
	$(CLANG) build/dce.ll -o build/final
	build/final

run-opt-stdout: set-up-mac target/debug/libllvmlib.$(EXT) diospyros.cpp 
	$(CLANG) -emit-llvm -S -Xclang -disable-O0-optnone -o build/clang.ll $(test)
	opt -S -always-inline --inline --mem2reg --scev-aa -simplifycfg --flattencfg --indvars -loops -loop-rotate --loop-simplify --loop-idiom --loop-instsimplify --licm --unroll-threshold=1000000 --loop-unroll --simplifycfg --instcombine --gvn  --mem2reg --dse --adce build/clang.ll -o build/opt.ll
	opt -S --cfl-steens-aa build/opt.ll -o build/aa.ll
	$(CLANG) -emit-llvm -S -Xclang -load -Xclang target/debug/libllvmlib.$(EXT) -mllvm -opt -mllvm -print=false build/aa.ll -o build/diospyros.ll
	opt -S --adce --dse build/diospyros.ll -o build/dce.ll
	cat build/dce.ll

no-opt-stdout: set-up-mac target/debug/libllvmlib.$(EXT) diospyros.cpp 
	$(CLANG) -emit-llvm -S -Xclang -disable-O0-optnone -o build/clang.ll $(test)
	opt -S -always-inline --inline --mem2reg --scev-aa -simplifycfg --flattencfg --indvars -loops -loop-rotate --loop-simplify --loop-idiom --loop-instsimplify --licm --unroll-threshold=1000000 --loop-unroll --simplifycfg --instcombine --gvn  --mem2reg --dse --adce build/clang.ll -o build/opt.ll
	opt -S --cfl-steens-aa build/opt.ll -o build/aa.ll
	$(CLANG) -emit-llvm -S -Xclang -load -Xclang target/debug/libllvmlib.$(EXT) -mllvm -opt=false -mllvm -print=false build/aa.ll -o build/diospyros.ll
	rm build/dce.ll
	opt -S --adce --dse build/diospyros.ll -o build/dce.ll
	cat build/dce.ll

run-diospyros: set-up-mac target/debug/libllvmlib.$(EXT) diospyros.cpp 
	$(CLANG) -emit-llvm -S -Xclang -load -Xclang target/debug/libllvmlib.$(EXT) -mllvm -opt=false -mllvm -print=false $(test) -o build/diospyros.ll

run-polybench: set-up-mac target/debug/libllvmlib.$(EXT) diospyros.cpp 
	$(CLANG) -I polybench-tests/utilities -I polybench-tests/linear-algebra/kernels/atax $(test) -emit-llvm -S -Xclang -disable-O0-optnone -o build/clang.ll 
	opt -S -always-inline --inline --mem2reg --scev-aa -simplifycfg --flattencfg --indvars -loops -loop-rotate --loop-simplify --loop-idiom --loop-instsimplify --licm --unroll-threshold=1000000 --loop-unroll --simplifycfg --instcombine --gvn  --mem2reg --dse --adce build/clang.ll -o build/opt.ll
	opt -S --cfl-steens-aa build/opt.ll -o build/aa.ll
	$(CLANG) -emit-llvm -S -Xclang -load -Xclang target/debug/libllvmlib.$(EXT) -mllvm -opt -mllvm -print=true build/aa.ll -o build/diospyros.ll
	opt -S --adce --dse build/diospyros.ll -o build/dce.ll
	$(CLANG) -I utilities polybench-tests/utilities/polybench.c build/dce.ll -o build/final
	build/final

test: set-up-mac runt.sh runt.toml target/debug/libllvmlib.$(EXT)
	runt
 
target/debug/libllvmlib.$(EXT): $(LIB)
	cargo build

set-up-mac: 
	$(SETUP)

clean:
	rm -r build/*
 
clean-all:
	rm -rf target
	rm -r build/*
