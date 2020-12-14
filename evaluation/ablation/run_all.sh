#!/bin/bash

echo "timeout,cycles"

for exp in `ls`; do
  if [[ -d $exp ]]; then
    pushd $exp > /dev/null
    echo -n "$exp," >> ../ablation.csv
    make --silent run >> ../ablation.csv
    popd > /dev/null
  fi
done
