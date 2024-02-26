#!/bin/bash
set -e
set -u

bam=$1
Peak=$2
#ctrl_bam=$3
out_path=$3

#convert seacr bed file to gff
# .gff must have the following columns:
# 1: chromosome (chr#)
# 2: unique ID for each constituent enhancer region
# 4: start of constituent
# 5: end of constituent
# 7: strand (+,-,.)
# 9: unique ID for each constituent enhancer region
# SEACR spec: 
# https://github.com/FredHutch/SEACR
#echo $out_path
mkdir -p $out_path
out_gff_name=$(basename $Peak)
gff=$out_path/${out_gff_name}.gff
touch $gff
r=$((1 + $RANDOM % 10))
awk -v OFS='\t' '{print $1,$6,"SEACR_Peak",$2,$3,$4,".",$6}'  $Peak >  $gff
sed -i '/^chr[[:alnum:]]\+_[^\s]\+\s/d;s/:/_/g;s/-/_/g;/^chrM/d' $gff
#head -10 $gff

#rose2 -g HG38 -i $gff -c $ctrl_bam -r $bam -o $out_path  -s 12500 -t 2500
#promblem with ROSE2 from conda repo - local install 
PYTHONPATH=/home/yup1/dev/bin/rose2/ROSE/lib:$PYTHONPATH
export PYTHONPATH
export PATH=/home/yup1/dev/bin/rose2/ROSE/bin:$PATH
rose2=/home/yup1/dev/bin/rose2/ROSE/bin/ROSE_main.py
rose2_map_gene=/home/yup1/dev/bin/rose2/ROSE/bin/ROSE_geneMapper.py

python $rose2 -g HG38 -i $gff  -r $bam -o $out_path  -s 12500 -t 2500
#rank_table=$( ls $out_path/*_SuperEnhancers.table.txt ) 
rank_table=$( ls $out_path/*_AllStitched.table.txt)
[ -e $rank_table ] && python $rose2_map_gene -g HG38 -i $rank_table
#rm $$.rank.txt
