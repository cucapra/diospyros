cargo build
/usr/local/opt/llvm/bin/clang -S -emit-llvm -Xclang -load -Xclang target/debug/libllvmlib.dylib mult.c