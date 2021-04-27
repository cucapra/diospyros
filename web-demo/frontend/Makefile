.PHONY: build get-diospyros deploy

DIOSPYOS:=../diospyros/diospyros/js/target/scala-2.13/diospyros-fastopt.js

build: static/js/bundle.js
	hugo

custom-js/node_modules:
	cd custom-js && yarn install

custom-js/bundle.js: custom-js/index.js custom-js/examples.js | custom-js/node_modules
	cd custom-js && yarn build

static/js/bundle.js: custom-js/bundle.js
	mv $< static/js/bundle.js

get-diospyros:
	# Assumes that the diospyros JavaScript file was generated.
	cp $(DIOSPYOS) custom-js/

deploy: build
	rsync -azvhP public/ coursewww:/users/rn359/coursewww/capra.cs.cornell.edu/htdocs/diospyros
