use std::process::Command;

fn main() {
    // Use `llvm-config` to get the appropriate flags for compiling our C++.
    let output = Command::new("llvm-config")
        .arg("--cxxflags")
        .output()
        .expect("llvm-config failed");
    let cxxflags = String::from_utf8(output.stdout).unwrap();

    // Build the C++ file.
    let mut build = cc::Build::new();
    build.cpp(true)
        .warnings(false)  // LLVM headers have lots of spurious warnings.
        .file("Diospyros/diospyros.cpp");
    for flag in cxxflags.split_ascii_whitespace() {
        build.flag(&flag);
    }
    build.compile("libdiospass.a");
}
