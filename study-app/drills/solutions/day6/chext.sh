#!/bin/bash

# chext.sh EXT        removes the extension .EXT from every file in the cwd ending in .EXT
# chext.sh SRC DST    changes the extension .SRC to .DST

for f in *."$1"; do
    # if nothing matches, the glob stays as the literal text *.EXT: skip it
    [[ -e $f ]] || continue
    base=${f%.*}
    if (( $# == 1 )); then
        mv "$f" "$base"
    else
        mv "$f" "$base.$2"
    fi
done
exit 0
