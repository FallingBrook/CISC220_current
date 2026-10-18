#!/bin/bash
# $1 = file of "name<TAB>mark" lines, $2 = file to save all sorted marks in
cut -f2 "$1" | sort -n -r | tee "$2" | head -n3
