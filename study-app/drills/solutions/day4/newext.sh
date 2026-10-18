#!/bin/bash

# newext.sh: rename file $1 so that its extension becomes $2

f=$1
ext=$2

base=${f%.*}
mv "$f" "$base.$ext"
