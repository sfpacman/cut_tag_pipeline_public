#!/bin/bash

ROSE2_ENHANCER_FILE=$1
#_AllEnhancers.table.txt
BAM_FILE=$2
OUTPUTFOLDER=$3
output_name=$4
GENOME=HG38
which python
coltron  -e $ROSE2_ENHANCER_FILE -b $BAM_FILE -g $GENOME -o $OUTPUTFOLDER -n $output_name