.PHONY: test build test-all

test: build

test-all: test build
	raco test src/*.rkt src/backend/*.rkt

build:
	raco exe --vv -o dios-example-gen src/example-gen.rkt
	raco exe --vv -o dios src/main.rkt

clean:
	rm -rf dios dios-example-gen
