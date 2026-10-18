#!/bin/bash

s=$1
printf %s "$s" | tr -d '0-9'
