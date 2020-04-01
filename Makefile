.PHONY: test build test-all

test: build

test-all: test build
	raco test --drdr src/*.rkt src/backend/*.rkt

build:
	raco exe -o dios-example-gen src/example-gen.rkt
	raco exe -o dios src/main.rkt

clean:
	rm -rf dios dios-example-gen
