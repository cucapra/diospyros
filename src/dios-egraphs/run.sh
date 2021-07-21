make -C build
cargo build
/usr/local/opt/llvm/bin/clang -Xclang -load -Xclang build/Diospyros/libDiospyrosPass.* -Xclang -load -Xclang target/debug/libllvmlib.dylib mult.c 
