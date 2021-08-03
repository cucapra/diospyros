mkdir .cargo
touch .cargo/config
echo '[target.x86_64-apple-darwin]
    rustflags = [
      "-C", "link-arg=-undefined",
      "-C", "link-arg=dynamic_lookup",
    ]' > .cargo/config