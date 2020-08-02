.PHONY: test build test-all

# By default, run two jobs
MAKEFLAGS += --jobs=2

RACKET_SRC := src/*.rkt src/examples/*.rkt src/backend/*.rkt

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

# TODO: separate out this into substeps
%-egg: build
	./dios-example-gen --only-spec -b $* -p $*-params -o $*-out
	cat $*-out/spec.rkt | python3 src/dios-egraphs/vec-dsl-conversion.py -p > $*-out/spec-egg.rkt
	cargo run --manifest-path src/dios-egraphs/Cargo.toml $*-out/spec-egg.rkt > $*-out/res.rkt
	./dios -e $*-out