#!/usr/bin/env bash
set -e

spikeInRef=$1
fastq_1=$2
fastq_2=$3
out_dir=$4
sample_name=$5
out_summary=$6
cores=2

genome=hg38
out=${sample_name}_${genome}_bowtie2_spike-in

## bowtie2-build path/to/Ecoli/fasta/Ecoli.fa /path/to/bowtie2Index/Ecoli
echo "bowtie2 --no-overlap --no-dovetail --end-to-end --very-sensitive --no-mixed --no-discordant --phred33 -I 10 -X 700 -p ${cores} -x ${spikeInRef} -1 $fastq_1 -2 $fastq_2  2> ${out_summary}.log | samtools view -1  -F 0x04 -b -S /dev/stdin  > $out_dir/${out}.bam"

bowtie2  --mm -p $cores --end-to-end --very-sensitive --no-mixed --no-discordant --phred33 -I 10 -X 700 \
 -x ${spikeInRef} -1 $fastq_1 -2 $fastq_2 2> ${out_summary}.log | samtools view -1  -F 0x04 -b -S /dev/stdin  > $out_dir/${out}.bam

#bowtie2 --no-overlap --no-dovetail --end-to-end --very-sensitive --no-mixed --no-discordant --phred33 -I 10 -X 700 -p ${cores} -x ${spikeInRef} -1 $fastq_1 -2 $fastq_2  2> $out_dir/${out_summary}.log | samtools view -1  -F 0x04 -b -S /dev/stdin  > $out_dir/${out}.bam

seqDepth=$( samtools view -F 0x04 $out_dir/${out}.bam | cut -f 1 | sort | uniq | wc -l )
#seqDepth=$((seqDepthDouble/2))
echo $seqDepth > $out_dir/${out}.seqDepth

