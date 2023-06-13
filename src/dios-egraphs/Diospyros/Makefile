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

run-opt: set-up-mac target/debug/libllvmlib.$(EXT) diospyros.cpp 
	@$(CLANG) -target arm64-apple-macos11 -mmacosx-version-min=11.0 -emit-llvm -S -Xclang -disable-O0-optnone -o build/clang.ll $(test)
	@opt -S -always-inline --inline --mem2reg --scev-aa -simplifycfg --flattencfg --indvars -loops -loop-rotate --loop-simplify --loop-idiom --loop-instsimplify --licm --unroll-threshold=1000000 --loop-unroll --simplifycfg --instcombine --gvn  --mem2reg --dse --adce build/clang.ll -o build/opt.ll
	@opt -S -load=target/debug/libllvmlib.$(EXT) --basic-aa --lsmovement --dse --adce build/opt.ll -o build/aa.ll
	@opt -S -load=target/debug/libllvmlib.$(EXT) --diospyros -opt -print=true build/aa.ll -o build/diospyros.ll
	@opt -S --adce --dse --gvn build/diospyros.ll -o build/dce.ll
	@$(CLANG) -target arm64-apple-macos11 -mmacosx-version-min=11.0 build/dce.ll -o build/final
	@build/final

run-baseline: set-up-mac target/debug/libllvmlib.$(EXT) diospyros.cpp 
	@$(CLANG) -target arm64-apple-macos11 -mmacosx-version-min=11.0 -emit-llvm -S -Xclang -disable-O0-optnone -o build/clang.ll $(test)
	@opt -S -always-inline --inline --mem2reg --scev-aa -simplifycfg --flattencfg --indvars -loops -loop-rotate --loop-simplify --loop-idiom --loop-instsimplify --licm --unroll-threshold=1000000 --loop-unroll --simplifycfg --instcombine --gvn  --mem2reg --dse --adce build/clang.ll -o build/opt.ll
	@opt -S --slp-vectorizer  build/opt.ll -o build/slp.ll
	@opt -S --adce --dse build/slp.ll -o build/dce.ll
	@$(CLANG) -target arm64-apple-macos11 -mmacosx-version-min=11.0 -o0 build/dce.ll -o build/final
	@build/final

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
	@$(CLANG) -emit-llvm -S -Xclang -disable-O0-optnone -o build/clang.ll $(test)
	@opt -S -always-inline --inline --mem2reg --scev-aa -simplifycfg --flattencfg --indvars -loops -loop-rotate --loop-simplify --loop-idiom --loop-instsimplify --licm --unroll-threshold=1000000 --loop-unroll --simplifycfg --instcombine --gvn  --mem2reg --dse --adce build/clang.ll -o build/opt.ll
	@opt -S --cfl-steens-aa build/opt.ll -o build/aa.ll
	@$(CLANG) -emit-llvm -S -Xclang -load -Xclang target/debug/libllvmlib.$(EXT) -mllvm -opt -mllvm -print=false build/aa.ll -o build/diospyros.ll
	@opt -S --adce --dse build/diospyros.ll -o build/dce.ll
	@cat build/dce.ll

no-opt-stdout: set-up-mac target/debug/libllvmlib.$(EXT) diospyros.cpp 
	@$(CLANG) -emit-llvm -S -Xclang -disable-O0-optnone -o build/clang.ll $(test)
	@opt -S -always-inline --inline --mem2reg --scev-aa -simplifycfg --flattencfg --indvars -loops -loop-rotate --loop-simplify --loop-idiom --loop-instsimplify --licm --unroll-threshold=1000000 --loop-unroll --simplifycfg --instcombine --gvn  --mem2reg --dse --adce build/clang.ll -o build/opt.ll
	@opt -S --cfl-steens-aa build/opt.ll -o build/aa.ll
	@$(CLANG) -emit-llvm -S -Xclang -load -Xclang target/debug/libllvmlib.$(EXT) -mllvm -opt=false -mllvm -print=false build/aa.ll -o build/diospyros.ll
	@rm build/dce.ll
	@opt -S --adce --dse build/diospyros.ll -o build/dce.ll
	@cat build/dce.ll

run-polybench: set-up-mac target/debug/libllvmlib.$(EXT) diospyros.cpp 
	$(CLANG) -I polybench-tests/utilities -I polybench-tests/linear-algebra/kernels/atax $(test) -emit-llvm -S -Xclang -disable-O0-optnone -o build/clang.ll 
	opt -S -always-inline --inline --mem2reg --scev-aa -simplifycfg --flattencfg --indvars -loops -loop-rotate --loop-simplify --loop-idiom --loop-instsimplify --licm --unroll-threshold=1000000 --loop-unroll --simplifycfg --instcombine --gvn  --mem2reg --dse --adce build/clang.ll -o build/opt.ll
	opt -S --cfl-steens-aa build/opt.ll -o build/aa.ll
	$(CLANG) -emit-llvm -S -Xclang -load -Xclang target/debug/libllvmlib.$(EXT) -mllvm -opt -mllvm -print=true build/aa.ll -o build/diospyros.ll
	opt -S --adce --dse build/diospyros.ll -o build/dce.ll
	$(CLANG) -I utilities polybench-tests/utilities/polybench.c build/dce.ll -o build/final
	build/final

test: set-up-mac target/debug/libllvmlib.$(EXT) diospyros.cpp 
	turnt c-tests/*.c
 
target/debug/libllvmlib.$(EXT): $(LIB)
	@cargo build

set-up-mac: 
	@$(SETUP)

clean:
	rm -r build/*
 
clean-all:
	rm -rf target
	rm -r build/*
