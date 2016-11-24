#!/bin/bash

# Usage: submit.sh Paramfile

# Create stopos pool. Removes any earlier pool
module load stopos
stopos create -p monee.pool 
stopos add -p monee.pool $1

NR_LINES=`cat $1 | wc -l`
let NR_NODES=(${NR_LINES}+11)/12

echo ${NR_NODES}

qsub -o logs -e logs -t 1-${NR_NODES} ${HOME}/monee/monee-master/scripts/run_monee.sh

showq -u $USER
