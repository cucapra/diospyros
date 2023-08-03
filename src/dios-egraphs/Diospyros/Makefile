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

run-slp:
	@$(CLANG) -target arm64-apple-macos11 -mmacosx-version-min=11.0 -emit-llvm -S -Xclang -disable-O0-optnone -o build/clang.ll $(test)
	@opt -S -always-inline --inline --mem2reg --scev-aa -simplifycfg --flattencfg --indvars -loops -loop-rotate --loop-simplify --loop-idiom --loop-instsimplify --licm --unroll-threshold=1000000 --loop-unroll --simplifycfg --instcombine --gvn  --mem2reg --dse --adce build/clang.ll -o build/opt.ll
	@opt -S --slp-vectorizer  build/opt.ll -o build/slp.ll
	@opt -S --adce --dse build/slp.ll -o build/dce.ll
	@$(CLANG) -target arm64-apple-macos11 -mmacosx-version-min=11.0 -o0 build/dce.ll -o build/final
	@build/final

run-baseline:
	@$(CLANG) -target arm64-apple-macos11 -mmacosx-version-min=11.0 -emit-llvm -S -Xclang -disable-O0-optnone -o build/clang.ll $(test)
	@$(CLANG) -target arm64-apple-macos11 -mmacosx-version-min=11.0 -O3 -fno-vectorize -fno-tree-vectorize -fno-slp-vectorize -o build/final build/clang.ll
	@build/final

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
