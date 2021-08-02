ifeq ($(shell uname),Darwin)
    EXT := dylib
	CLANG := /usr/local/opt/llvm/bin/clang
		LIB := src/lib.rs Cargo.toml .cargo/config
else
    EXT := so
	CLANG = clang
		LIB := src/lib.rs Cargo.toml
endif

.PHONY: target/debug/libllvmlib.$(EXT)

run: target/debug/libllvmlib.$(EXT) diospyros.cpp 
	$(CLANG) -Xclang -load -Xclang target/debug/libllvmlib.$(EXT) $(test)

emit: target/debug/libllvmlib.$(EXT) diospyros.cpp 
	$(CLANG) -Xclang -load -Xclang target/debug/libllvmlib.$(EXT) -emit-llvm -S -o - $(test)

emit-o2: target/debug/libllvmlib.$(EXT) diospyros.cpp 
	$(CLANG) -O2 -Xclang -load -Xclang target/debug/libllvmlib.$(EXT) -emit-llvm -S -o - $(test)

runt: runt.sh runt.toml 
	runt
 
target/debug/libllvmlib.$(EXT): $(LIB)
	cargo build
 
clean:
	rm -rf target
