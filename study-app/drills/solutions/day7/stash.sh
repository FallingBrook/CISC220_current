#!/bin/bash

# stash.sh: move each file into DIR/.stash/EXT where DIR is the directory
# containing the file and EXT is the file's extension

if (( $# == 0 )); then
    echo "Usage: stash.sh file..." >&2
    exit 1
fi

status=0
for path in "$@"; do
    # skip anything that is not a regular file
    if [[ ! -f $path ]]; then
        echo "stash.sh: $path is not a regular file" >&2
        status=2
        continue
    fi

    # directory that the file is in
    if [[ $path == */* ]]; then
        dir=${path%/*}
    else
        dir=.
    fi

    # extension of the filename (other if there is no .)
    name=${path##*/}
    if [[ $name == *.* ]]; then
        ext=${name##*.}
    else
        ext=other
    fi

    mkdir -p "$dir/.stash/$ext"
    chmod 700 "$dir/.stash"
    echo "stashing $path in $dir/.stash/$ext"
    mv "$path" "$dir/.stash/$ext"
done
exit "$status"
