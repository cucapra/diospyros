ifeq ($(shell uname),Darwin)
    EXT := dylib
	CLANG := /usr/local/opt/llvm/bin/clang
else
    EXT := so
	CLANG = clang
endif

mac: target/debug/libllvmlib.$(EXT) diospyros.cpp 
	$(CLANG) -Xclang -load -Xclang target/debug/libllvmlib.$(EXT) llvm-tests/mac.c

run: target/debug/libllvmlib.$(EXT) diospyros.cpp 
	$(CLANG) -Xclang -load -Xclang target/debug/libllvmlib.$(EXT) $(var)

emit: target/debug/libllvmlib.$(EXT) diospyros.cpp 
	$(CLANG) -S -emit-llvm -Xclang -load -Xclang target/debug/libllvmlib.$(EXT) $(var)

runt: runt.sh runt.toml 
	runt
 
target/debug/libllvmlib.$(EXT): src/lib.rs Cargo.toml .cargo/config
	cargo build
 
clean:
	rm -rf target
