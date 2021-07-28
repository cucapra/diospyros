rm a.out
cargo build
/usr/local/opt/llvm/bin/clang -Xclang -load -Xclang target/debug/libllvmlib.dylib a.c
./a.out