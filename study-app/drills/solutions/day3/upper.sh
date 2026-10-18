#!/bin/bash
# print $1 in uppercase; quotes keep spaces and * exactly as given
echo "$1" | tr a-z A-Z
