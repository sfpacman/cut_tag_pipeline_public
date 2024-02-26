#!/usr/bin/env bash
set -e
set -u
ref=$1
target_ref_bed=$2
fastq_1=$3
fastq_2=$4
out_dir=$5
sample_name=$6
out_summary=$7

#out_dir=${projPath}/alignment/bam
cores=2
genome=hg38
out=${sample_name}_${genome}_bowtie2

#source "/home/yup1/miniconda3/etc/profile.d/conda.sh"
#conda activate encode-chip-seq-pipeline


#bowtie2 --mm -p $core --local --very-sensitive-local --no-unal --no-mixed --no-discordant --phred33 -I 10 -X 700  \
#-x $ref -1 $fastq_1 -2 $fastq_2 2> ${out_summary}.log | samtools view -1  -F 0x04 -b -S /dev/stdin  > $out_dir/${out}.bam  

bowtie2  --mm -p $cores --end-to-end --very-sensitive --no-mixed --no-discordant --phred33 -I 10 -X 700 \
 -x $ref -1 $fastq_1 -2 $fastq_2 2> ${out_summary}.log | samtools view -1  -F 0x04 -b -S /dev/stdin  > $out_dir/${out}.bam

samtools view -L $target_ref_bed -o $out_dir/$$.out.bam $out_dir/${out}.bam

mv $out_dir/$$.out.bam $out_dir/${out}.bam

seqDepth=$( samtools view -F 0x04 $out_dir/${out}.bam | cut -f 1 | sort | uniq | wc -l )

echo $seqDepth > $out_dir/${out}.seqDepth
