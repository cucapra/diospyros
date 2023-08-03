use std::process::Command;

fn main() {
    // Use `llvm-config` to get the appropriate flags for compiling our C++.
    let output = Command::new("llvm-config")
        .arg("--cxxflags")
        .output()
        .expect("llvm-config failed");
    let cxxflags = String::from_utf8(output.stdout).unwrap();

    // Build the LoadStoreMovement C++ file.
    let mut build_lsm = cc::Build::new();
    build_lsm
        .cpp(true)
        .warnings(false) // LLVM headers have lots of spurious warnings.
        .file("LoadStoreMovement.cpp");
    for flag in cxxflags.split_ascii_whitespace() {
        build_lsm.flag(&flag);
    }
    build_lsm.flag("-fexceptions");
    build_lsm.compile("liblsmpass.a");

    // Build the Diospyros C++ file.
    let mut build_diospyros = cc::Build::new();
    build_diospyros
        .cpp(true)
        .warnings(false) // LLVM headers have lots of spurious warnings.
        .file("diospyros.cpp");
    for flag in cxxflags.split_ascii_whitespace() {
        build_diospyros.flag(&flag);
    }
    build_diospyros.flag("-fexceptions");
    build_diospyros.compile("libdiospass.a");

    // Build the AddressRewriting C++ file.
    let mut build_address_rewriting = cc::Build::new();
    build_address_rewriting
        .cpp(true)
        .warnings(false) // LLVM headers have lots of spurious warnings.
        .file("AddressRewriting.cpp");
    for flag in cxxflags.split_ascii_whitespace() {
        build_address_rewriting.flag(&flag);
    }
    build_address_rewriting.flag("-fexceptions");
    build_address_rewriting.compile("libadrwpass.a");
}
