#!/bin/bash

# Define our default folder and file names.
OUT="out"
JSON="$OUT/combined.json"
API="$OUT/api.js"

# Check for folders and files.
# Create them if the are missing.
# Clear everything out if they exist.
if [[ ! -d $OUT ]]; then
  echo "Creating output directory..."
  mkdir out
else
  echo "Clearing output directory..."
  if [[ -f $JSON ]]; then
    rm $JSON
  fi
  if [[ -f $API ]]; then
    rm $API
  fi
fi

echo "Compiling..."
find ../contracts -name "*.sol" -exec solc --combined-json abi,bin {} + > $JSON
echo "Done..."

echo
echo "--- Setup Instructions ---"

echo "1: Open setup page and upload combined.json file."
echo "2: Download resulting api.js and place it in ./out directory."
echo "3: Run ./init.sh script."
echo "4: Open manager page and register all contracts."
