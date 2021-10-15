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
	opt -S --mem2reg --indvars --loop-simplify --loop-instsimplify --licm --loop-unroll --simplifycfg clang.ll -o opt.ll
	$(CLANG) -emit-llvm -S -Xclang -load -Xclang target/debug/libllvmlib.$(EXT) -o finish.ll opt.ll

run-opt: set-up-mac target/debug/libllvmlib.$(EXT) diospyros.cpp 
	$(CLANG) -emit-llvm -S -Xclang -disable-O0-optnone -o clang.ll $(test)
	opt -S --mem2reg --indvars --loop-simplify --loop-instsimplify --licm --loop-unroll --simplifycfg clang.ll -o opt.ll
	$(CLANG) -Xclang -load -Xclang target/debug/libllvmlib.$(EXT) opt.ll
	./a.out

test: set-up-mac runt.sh runt.toml target/debug/libllvmlib.$(EXT)
	runt
 
target/debug/libllvmlib.$(EXT): $(LIB)
	cargo build

set-up-mac: 
	$(SETUP)
 
clean:
	rm -rf target
