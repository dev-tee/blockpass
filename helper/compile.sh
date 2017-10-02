#!/bin/bash

if [[ ! -d out ]]; then
  echo "Creating output directory..."
  mkdir out
fi

echo "Compiling..."
find ../contracts -name "*.sol" -exec solc --combined-json abi,bin {} + > out/combined.json
echo "Done..."

echo
echo "--- Setup Instructions ---"

echo "1: Open setup page and upload combined.json file."
echo "2: Download resulting api.js and place it in ./out directory."
echo "3: Run ./init.sh script."