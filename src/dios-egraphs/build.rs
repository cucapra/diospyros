use std::process::Command;

fn main() {
    let output = Command::new("llvm-config")
        .arg("--cxxflags")
        .output()
        .expect("llvm-config failed");
    let cxxflags = String::from_utf8(output.stdout).unwrap();

    let mut build = cc::Build::new();
    build.cpp(true)
        .file("Diospyros/diospyros.cpp");
    for flag in cxxflags.split_ascii_whitespace() {
        build.flag(&flag);
    }
    build.compile("libdiospass.a");
}
