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

run-out: target/debug/libllvmlib.$(EXT) diospyros.cpp 
	$(CLANG) -Xclang -load -Xclang target/debug/libllvmlib.$(EXT) $(test)
	./a.out

emit: target/debug/libllvmlib.$(EXT) diospyros.cpp 
	$(CLANG) -Xclang -load -Xclang target/debug/libllvmlib.$(EXT) -emit-llvm -S -o - $(test)

emit-o2: target/debug/libllvmlib.$(EXT) diospyros.cpp 
	$(CLANG) -O2 -Xclang -load -Xclang target/debug/libllvmlib.$(EXT) -emit-llvm -S -o - $(test)

test: runt.sh runt.toml target/debug/libllvmlib.$(EXT)
	runt
 
target/debug/libllvmlib.$(EXT): $(LIB)
	cargo build
 
clean:
	rm -rf target
