#!/bin/bash
set -e
set -u 

bam=$1
ctrl_bam=$2
out_dir=$3
ctrl_tag_folder=$out_dir/ctrl_tag
sample_tag_folder=$out_dir/sample_tag
sample_peak=$( basename $bam | sed -s 's/.bam/_homer.bed/' )

mkdir -p  $out_dir
mkdir -p  $ctrl_tag_folder
mkdir -p  $sample_tag_folder

makeTagDirectory $sample_tag_folder $bam
makeTagDirectory $ctrl_tag_folder $ctrl_bam
findPeaks $sample_tag_folder -style factor -i $ctrl_tag_folder > $out_dir/peak.txt
pos2bed.pl $out_dir/peak.txt  > $out_dir/peak.bed


awk -F"\t" 'BEGIN{OFS="\t"}(NR==FNR && /^[^#]/){ ext=$0;gsub("^.+?\t\\+","",ext); append[$1]=ext ;next};
     { print$0,append[$4] }
    '  $out_dir/peak.txt  $out_dir/peak.bed | sed 's/ \+//g' > $out_dir/$sample_peak
    
rm $out_dir/peak.txt $out_dir/peak.bed

rm $sample_tag_folder/*
rm $ctrl_tag_folder/*