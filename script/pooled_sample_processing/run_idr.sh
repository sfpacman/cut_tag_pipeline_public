#!/bin/bash
set -e
set -u 

REP1_PEAK_FILE=$1
REP2_PEAK_FILE=$2
POOLED_PEAK_FILE=$3
IDR_OUTPUT=$4

IDR_THRESH=0.05
mkdir -p $IDR_OUTPUT
sample_name=$( basename $POOLED_PEAK_FILE | sed 's/\.narrowPeak//g')

peak1=${IDR_OUTPUT}/$(basename REP1_PEAK_FILE)_temp
peak2=${IDR_OUTPUT}/$(basename REP2_PEAK_FILE)_temp

sort -k8,8nr $REP1_PEAK_FILE > $peak1
sort -k8,8nr $REP2_PEAK_FILE > $peak2

idr --samples $peak1 $peak2 \
    --peak-list ${POOLED_PEAK_FILE} \
    --input-file-type narrowPeak --output-file ${IDR_OUTPUT}/${sample_name}.narrowPeak --rank signal.value --soft-idr-threshold ${IDR_THRESH} --plot --use-best-multisummit-IDR  --use-nonoverlapping-peaks 2>> $IDR_OUTPUT/IDR_Peak_summary.txt

rm $peak1 $peak2