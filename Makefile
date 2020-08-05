.PHONY: test build test-all
.PRECIOUS: %-out/res.rkt %-out/spec-egg.rkt

# By default, run two jobs
MAKEFLAGS += --jobs=2

RACKET_SRC := src/*.rkt src/examples/*.rkt src/backend/*.rkt

CARGO_FLAGS := --release

test: build

test-all: test build
	raco test --drdr src/*.rkt src/backend/*.rkt

build: dios dios-example-gen

dios: $(RACKET_SRC)
	raco exe -o dios src/main.rkt

dios-example-gen: $(RACKET_SRC)
	raco exe -o dios-example-gen src/example-gen.rkt

clean:
	rm -rf dios dios-example-gen

# Build spec
%-out: %-params dios dios-example-gen
	./dios-example-gen --only-spec -b $* -p  $< -o $@

# Pre-process spec for egg
%-out/spec-egg.rkt: %-out src/dios-egraphs/vec-dsl-conversion.py
	cat $*-out/spec.rkt | python3 src/dios-egraphs/vec-dsl-conversion.py -p > $@

# Run egg rewriter
%-out/res.rkt: %-out/spec-egg.rkt
	cargo run $(CARGO_FLAGS) --manifest-path src/dios-egraphs/Cargo.toml $< > $@

# Backend code gen
%-egg: %-out/res.rkt
	./dios -e -o $*-out/kernel.c $*-out
