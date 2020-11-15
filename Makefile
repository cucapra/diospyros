.PHONY: test build test-all
.PRECIOUS: %-out/res.rkt

# Default vector width of 4
VEC_WIDTH := 4

# By default, run one jobs
MAKEFLAGS += --jobs=1

RACKET_SRC := src/*.rkt src/examples/*.rkt src/backend/*.rkt

CARGO_FLAGS := --release

EGG_FLAGS := --no-ac
ifeq ($(VEC_WIDTH),2)
	EGG_BUILD_FLAGS := --features vec_width_2
else ifeq ($(VEC_WIDTH),8)
	EGG_BUILD_FLAGS := --features vec_width_8
else ifneq ($(VEC_WIDTH),4)
	$(error Bad vector width, currently 2, 4, or 8 supported)
endif

PY := pypy3

test: build

test-racket: test build
	raco test --drdr src/*.rkt src/backend/*.rkt

test-rust:
	cargo test --manifest-path src/dios-egraphs/Cargo.toml

test-all: test-racket test-rust

build: dios dios-example-gen

dios: $(RACKET_SRC)
	raco exe -o dios src/main.rkt

dios-example-gen: $(RACKET_SRC)
	raco exe -o dios-example-gen src/example-gen.rkt

clean:
	rm -rf dios dios-example-gen

# Build spec
%-out: %-params
	./dios-example-gen -w $(VEC_WIDTH) -b $* -p  $< -o $@

# Run egg rewriter
%-out/res.rkt: %-out/spec.rkt
	cargo run $(CARGO_FLAGS) --manifest-path src/dios-egraphs/Cargo.toml $(EGG_BUILD_FLAGS) -- $< $(EGG_FLAGS)  > $@

# Backend code gen
%-egg: %-out/res.rkt
	./dios $(BACKEND_FLAGS) -w $(VEC_WIDTH) -e -o $*-out/kernel.c $*-out
