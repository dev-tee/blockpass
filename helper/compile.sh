#!/bin/bash

echo "compiling..."
mkdir out
find ../contracts -name "*.sol" -exec solc --combined-json abi,bin {} + > out/combined.json