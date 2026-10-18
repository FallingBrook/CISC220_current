#!/bin/bash

# checksubs.sh FILE...
# prints (to stderr) the name of each subdirectory of the cwd that is missing
# one of the FILEs as a regular file; exit status 1 if any were missing, else 0

status=0
for d in */; do
    [[ -d $d ]] || continue          # no subdirectories: */ did not match
    for f in "$@"; do
        if [[ ! -f $d$f ]]; then
            echo "$d" >&2
            status=1
            break                    # report each directory only once
        fi
    done
done
exit "$status"
