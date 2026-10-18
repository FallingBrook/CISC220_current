#!/bin/bash
# print the student numbers (field 3) of the classlist file named by $1, sorted
cut -f3 "$1" | sort
