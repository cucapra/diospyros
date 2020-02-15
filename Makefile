.PHONY: test build

test:
	raco test src/*.rkt

build:
	raco exe --vv -o dios src/main.rkt
