#!/usr/bin/env bash
set -e
set -u

bam=$1
out_dir=$2
genome="hg38"
out_sam_name=${3}_${genome}
scale_factor_file=$4
chrom_size=$5

echo "converting $(basename $bam) to $out_sam_name"
[ -e $out_dir ] || mkdir -p $out_dir
## Convert into bed file format
bedtools bamtobed -i $bam -bedpe > $out_dir/${out_sam_name}_bowtie2.bed

## Keep the read pairs that are on the same chromosome and fragment length less than 1000bp.
awk -F " " '$1==$4 && $6-$2 < 1000 {print $0}' $out_dir/${out_sam_name}_bowtie2.bed > $out_dir/${out_sam_name}_bowtie2_clean.bed

## Only extract the fragment related columns
awk -F " " 'BEGIN{OFS="\t"}{print $1,$2,$6}' $out_dir/${out_sam_name}_bowtie2_clean.bed | sort -k1,1 -k2,2n -k3,3n  > $out_dir/${out_sam_name}_bowtie2_fragments.bed
mv $out_dir/${out_sam_name}_bowtie2_clean.bed $out_dir/${out_sam_name}_bowtie2.bed
# rm $out_dir/${out_sam_name}_bowtie2_clean.bed
## convert bedgraph
[ -e $scale_factor_file ] &&  scale_factor=$(cat $scale_factor_file | sed 's/\s//g') || scale_factor=1
echo "scale factor is $scale_factor"

bedtools genomecov -bg -scale $scale_factor -i $out_dir/${out_sam_name}_bowtie2_fragments.bed -g $chrom_size > $out_dir/${out_sam_name}_bowtie2_fragments_normalized.bedgraph
rm $out_dir/${out_sam_name}_bowtie2_fragments.bed
