#!/usr/bin/env bash
set -e
set -u

raw_fastq1=$1
raw_fastq2=$2
out_dir=$3
sample_name=$4
script_dir=$5
ref_dir=$6
skip_trimmed=$7
no_rose2=$8
no_spikein=$9
peak_caller=$10
ctrl_bedgraph=$11
ctrl_bam=$12

alignment_folder=${out_dir}/alignment/bam
peak_folder=${out_dir}/peak_calling/macs2

mkdir -p $alignment_folder
touch $alignment_folder/${sample_name}_hg38_bowtie2_sorted_rmDup_qualityScore_2_sorted.bam
mkdir -p $peak_folder/peak_calling/macs2/
touch $peak_folder/peak_calling/macs2/${sample_name}_no_ctrl_peaks.narrowPeak