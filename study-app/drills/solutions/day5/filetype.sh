#!/bin/bash

# filetype.sh: describe the file named by the first argument

file=$1
if [[ ! -e $file ]]; then
    echo "$file does not exist" >&2
    exit 1
fi

if [[ -d $file ]]; then
    echo "$file is a directory"
elif [[ -f $file ]]; then
    if [[ -s $file ]]; then
        echo "$file is a regular file"
    else
        echo "$file is an empty regular file"
    fi
    if [[ -x $file ]]; then
        echo "$file is executable"
    fi
fi
