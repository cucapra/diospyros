.PHONY: test build

test:
	raco test src/*.rkt

build:
	raco exe --vv -o dios-example-gen src/main.rkt
