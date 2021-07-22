cargo build
/usr/local/opt/llvm/bin/clang -Xclang -load -Xclang target/debug/libllvmlib.dylib mult.c