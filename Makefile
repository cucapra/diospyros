.PHONY: test build test-all dios-egraphs
.PRECIOUS: %-out/res.rkt

MK_DIR := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))

# Default vector width of 4
VEC_WIDTH := 4

# By default, run one jobs
MAKEFLAGS += --jobs=1

RACKET_SRC := $(MK_DIR)/src/*.rkt $(MK_DIR)/src/examples/*.rkt $(MK_DIR)/src/backend/*.rkt

CARGO_FLAGS := --release

EGG_FLAGS := --no-ac
ifeq ($(VEC_WIDTH),2)
	EGG_BUILD_FLAGS := --features vec_width_2
else ifeq ($(VEC_WIDTH),8)
	EGG_BUILD_FLAGS := --features vec_width_8
else ifneq ($(VEC_WIDTH),4)
	$(error Bad vector width, currently 2, 4, or 8 supported)
endif

build: dios dios-example-gen dios-egraphs

test: test-racket test-rust test-cdios

test-racket: build
	raco test --drdr $(MK_DIR)/src/*.rkt $(MK_DIR)/src/backend/*.rkt

test-rust:
	cargo test --manifest-path $(MK_DIR)/src/dios-egraphs/Cargo.toml

test-cdios:
	cd $(MK_DIR)
	runt

test-all: test-racket test-rust

dios-egraphs:
	cargo build --manifest-path $(MK_DIR)/src/dios-egraphs/Cargo.toml

dios: $(RACKET_SRC)
	raco exe -o $(MK_DIR)/dios $(MK_DIR)/src/main.rkt

dios-example-gen: $(RACKET_SRC)
	raco exe -o $(MK_DIR)/dios-example-gen $(MK_DIR)/src/example-gen.rkt

clean:
	rm -rf $(MK_DIR)/dios $(MK_DIR)/dios-example-gen $(MK_DIR)/__pycache__ $(MK_DIR)/src/compiled $(MK_DIR)/src/*~ build *-out/

# Build spec
%-out: %-params
	$(MK_DIR)/dios-example-gen -w $(VEC_WIDTH) -b $* -p  $< -o $@

# Run egg rewriter
%-out/res.rkt: %-out
	cargo run $(CARGO_FLAGS) --manifest-path $(MK_DIR)/src/dios-egraphs/Cargo.toml $(EGG_BUILD_FLAGS) -- $</spec.rkt $(EGG_FLAGS)  > $@

# Backend code gen
%-egg: %-out/res.rkt
	$(MK_DIR)/dios $(BACKEND_FLAGS) -w $(VEC_WIDTH) -e -o $*-out/kernel.c $*-out
