#!/usr/bin/env bash
set -e
set -u

output_dir=$1
input_bam=$2
sample_name=$3
#$projPath/alignment
output_bam_name=$( basename $input_bam | sed 's/.bam$//g' )
mkdir -p $output_dir/picard_summary

## Sort by coordinate
picard SortSam I="${input_bam}" O="$output_dir/${output_bam_name}_sorted.bam" SORT_ORDER=coordinate

## mark duplicates
#picard MarkDuplicates I=$output_dir/${output_bam_name}_sorted.bam O=$output_dir/${output_bam_name}_sorted_dupMarked.bam METRICS_FILE=$output_dir/picard_summary/${output_bam_name}_picard_dupMark.txt

## remove duplicates
picard MarkDuplicates I=$output_dir/${output_bam_name}_sorted.bam O=$output_dir/${output_bam_name}_sorted_rmDup.bam REMOVE_DUPLICATES=true METRICS_FILE=$output_dir/picard_summary/${output_bam_name}_picard_rmDup.txt
