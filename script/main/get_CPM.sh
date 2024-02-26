#!/bin/bash 
set -e 
set -u

bam=$1
out_bw=$2

[ -e ${bam}.bai ] || tabix $bam

hg_38_size=2913022398

 bamCoverage --bam $bam -o $out_bw --binSize 50 --normalizeUsing CPM --effectiveGenomeSize $hg_38_size
