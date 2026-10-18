#!/bin/bash

# trash.sh: move a file into a hidden .trash directory next to it

pathname=$1

# Step 1: the directory part of the pathname
dir=${pathname%/*}

# Step 2
trashdir=$dir/.trash
mkdir "$trashdir"

# Step 3
chmod 700 "$trashdir"

# Step 4
echo "moving $pathname to the trashcan"

# Step 5
mv "$pathname" "$trashdir"
