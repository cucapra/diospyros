.PHONY: test build

test:
	raco test src/*.rkt src/backend/*.rkt

build:
	raco exe --vv -o dios-example-gen src/example-gen.rkt
	raco exe --vv -o dios src/main.rkt
