#!/usr/bin/env bash
set -e
set -u

output=$1
fastq=$2

fastqc -o $output -f fastq $fastq
