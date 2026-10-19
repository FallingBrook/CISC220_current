#!/bin/bash

# upper.sh: print $1 in uppercase; the quotes keep spaces and * exactly as given

echo "$1" | tr a-z A-Z
