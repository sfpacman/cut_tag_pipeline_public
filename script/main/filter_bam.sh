#!/usr/bin/env bash
bam=$1
out_dir=$2
out_bam_prefix=$( basename $bam | sed 's/\.bam$//g' )
minQualityScore=2

samtools view -q $minQualityScore -b $bam -o $out_dir/${out_bam_prefix}_qualityScore_${minQualityScore}.bam
#cp $bam $out_dir/${out_bam_prefix}_qualityScore_${minQualityScore}.bam
samtools sort -n  -o $out_dir/${out_bam_prefix}_qualityScore_${minQualityScore}_sorted.bam $out_dir/${out_bam_prefix}_qualityScore_${minQualityScore}.bam
samtools fixmate $out_dir/${out_bam_prefix}_qualityScore_${minQualityScore}_sorted.bam $out_dir/${out_bam_prefix}_qualityScore_${minQualityScore}_sorted_by_name_fixed.bam
#ls $out_dir/${out_bam_prefix}_qualityScore_${minQualityScore}_sorted_fixed.bam
samtools sort -o $out_dir/${out_bam_prefix}_qualityScore_${minQualityScore}_sorted.bam  $out_dir/${out_bam_prefix}_qualityScore_${minQualityScore}_sorted_by_name_fixed.bam
samtools view -bf 0x2 -o $out_dir/${out_bam_prefix}_qualityScore_${minQualityScore}_sorted_fixed.bam $out_dir/${out_bam_prefix}_qualityScore_${minQualityScore}_sorted.bam
mv $out_dir/${out_bam_prefix}_qualityScore_${minQualityScore}_sorted_fixed.bam $out_dir/${out_bam_prefix}_qualityScore_${minQualityScore}_sorted.bam
samtools index $out_dir/${out_bam_prefix}_qualityScore_${minQualityScore}_sorted.bam
