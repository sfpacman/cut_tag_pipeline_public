#!/usr/bin/env bash

raw_fastq1=$1
raw_fastq2=$2
out_dir=$3
sample_name=$4
skip_trimmed=$5
no_spikein=$6
ctrl_bedgraph=$7
ctrl_bam=$8

cd $out_dir
script_dir="/home/yup1/dev/cut_n_tag/cut_tag_pipeline_v1"

alignment_folder=${out_dir}/alignment/bam
ref="/media/Data03/public_data/Genome/bowtie2_idx/GRCh38_no_alt_analysis_set_GCA_000001405.15.fasta"

bed_folder=${out_dir}/alignment/bed
genome=hg38
peak_folder=${out_dir}/peak_calling/SEACR
sample_bedgraph=$( ls ${bed_folder}/*_bowtie2_fragments_normalized.bedgraph | head -1 )

#bash $script_dir/run_seacr.sh $sample_bedgraph "$peak_folder/${sample_name}_$genome" $ctrl_bedgraph

#run ROSE2
peak_folder=${out_dir}/peak_calling/ROSE2
SEACR_peaks=$( ls ${out_dir}/peak_calling/SEACR/*_ctrl.peak.stringent.bed )
bam=$( ls $alignment_folder/* | grep qualityScore | grep "_rmDup" | grep "_sorted.bam$")
for peak in $SEACR_peaks;do
echo $bam $peak $peak_folder
  bash $script_dir/run_rose2.sh $bam $peak $peak_folder
done
