#!/bin/bash

# info.sh: describe how the script was called

echo "script: ${0##*/}"
echo "count: $#"
echo "first: $1"
echo "second: $2"
