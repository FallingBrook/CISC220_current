#!/bin/bash

# copyperm.sh: copy the permissions of file $1 to file $2

src=$1
dest=$2

# permissions of src as three octal digits, e.g. 640
perm=$(stat -c %a "$src")

chmod "$perm" "$dest"
