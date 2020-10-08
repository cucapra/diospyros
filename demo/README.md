# Diospyros Demo

Welcome to the ultimate web experience for program synthesis for compilers.

## Requirements

The demo uses the finest selection of web frameworks. Please install them.

### Frontend
1. Install [Hugo][] (= 0.65.1).
1. Install [yarn][].
2. Run the following to install the theme.:
```
cd frontend/themes
git clone https://github.com/halogenica/beautifulhugo.git beautifulhugo
cd ../..
```
3. Install the dependencies for JavaScript interaction
```
cd frontend/custom-js
yarn install && yarn build
```

### Backend
1. Install flask: `python3 -m pip install flask`


## Building

You are now ready to begin your journey.

1. Start the backend server: `python3 serve.py`
2. Start the frontend generator: `cd frontend && hugo serve`
3. Navigate to the link provided by the frontend compiler.

[hugo]: https://gohugo.io/getting-started/installing/
[yarn]: https://classic.yarnpkg.com/en/docs/install/#mac-stable
