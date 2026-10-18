#!/bin/bash

path=$1
echo "${path##*/}"
echo "${path%/*}"
