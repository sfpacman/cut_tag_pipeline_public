#!/bin/bash

bam=$1
out_path=$2

samtools view -F 0x04 $bam | awk -F'\t' 'function abs(x){return ((x < 0.0) ? -x : x)} {print abs($9)}' | sort | uniq -c | awk -v OFS="\t" '{print $2, $1/2}' > $out_path