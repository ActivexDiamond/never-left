#!/bin/bash

result=${PWD##*/}          # to assign to a variable
result=${result:-/}        # to correct for the case where PWD is / (root)
echo $PWD

cd game
echo "run.sh: Executing 'love-git .'"
love-git .
