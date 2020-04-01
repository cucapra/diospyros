.PHONY: test build test-all dios dios-example-gen

test: build

test-all: test build
	raco test --drdr src/*.rkt src/backend/*.rkt

build: dios dios-example-gen

dios:
	raco exe -o dios src/main.rkt

dios-example-gen:
	raco exe -o dios-example-gen src/example-gen.rkt

clean:
	rm -rf dios dios-example-gen
