#!/bin/bash

set -euf -o pipefail

echo "name,cycles" >> ../ablation.csv

for exp in $(ls); do
  if [[ -d "$exp" && "$exp" != "base" ]]; then
    pushd "$exp" > /dev/null
    echo -n "$exp," >> ../ablation.csv
    make --silent run >> ../ablation.csv
    popd > /dev/null
  fi
done
