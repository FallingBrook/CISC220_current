#!/bin/bash

# names.sh FILE   FILE has lines "number,last,first"; prints "first last (number)" for each,
# skipping lines that start with #

while IFS="," read -r num last first; do
    if [[ $num =~ ^# ]]; then
        continue
    fi
    echo "$first $last ($num)"
done < "$1"
