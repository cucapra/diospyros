.PHONY: build get-dahlia deploy

DAHLIA:=../dahlia/dahlia/js/target/scala-2.13/dahlia-fastopt.js

build: static/js/bundle.js
	hugo

custom-js/node_modules:
	cd custom-js && yarn install

custom-js/bundle.js: custom-js/index.js custom-js/examples.js | custom-js/node_modules
	cd custom-js && yarn build

static/js/bundle.js: custom-js/bundle.js
	mv $< static/js/bundle.js

get-dahlia:
	# Assumes that the dahlia JavaScript file was generated.
	cp $(DAHLIA) custom-js/

deploy: build
	rsync -azvhP public/ coursewww:/users/rn359/coursewww/capra.cs.cornell.edu/htdocs/dahlia
