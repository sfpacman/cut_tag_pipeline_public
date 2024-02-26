#!/usr/bin/env bash
set -e
set -u

fastq1=$1
fastq2=$2
basebname=trimmed_reads/$3
#adpater=/home/yup1/miniconda3/envs/ngs/share/trimmomatic-0.39-1/adapters/NexteraPE-PE.fa
adpater=$4

mkdir -p trimmed_reads
trimmomatic PE $fastq1 $fastq2  -baseout ${basebname}.fastq.gz ILLUMINACLIP:$adpater:4:30:10 MINLEN:30



