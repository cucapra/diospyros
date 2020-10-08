## Diospyros Demo

Demo webpage for the Dahlia Programming language.

### Prerequisites

1. Install Hugo (= 0.65.1)
2. (Optional for local builds) Install [entr][].
4. Run `make`. This will install the dependencies for `custom-js/` and generate
   the website under the `public/` folder.

[entr]: http://eradman.com/entrproject/

### Local builds

There are two components to the website, the static webpage and the custom
JavaScript (which contains all the examples).

1. Run the following command to automatically rebuild the JavaScript dependencies
   whenever a file in `custom-js/` is changed:
   ```
   cd custom-js && find *.js | entr -c yarn build
   ```
2. Run `hugo server -w` in the repository root. This will serve the webpage
   to [localhost:1313/dahlia](localhost:1313/dahlia).


### Adding new exampls

All the examples live in `custom-js/examples.js`. Add a new example by
adding a new object in the same style as the existing examples.

If running a local build, the file should be automatically rebuilt and the example
should up in the list. If it doesn't show up, check the console for any errors.
It's likely that the example was malformed or a the script failed.

### Credits

Based on the [Dahlia demo website](https://github.com/cucapra/dahlia-demo).
