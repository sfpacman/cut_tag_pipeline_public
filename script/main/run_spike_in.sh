#!/usr/bin/env bash
set -e
set -u

out_dir=$1
sample_name=$2

fastq1=$( ls $out_dir/trimmed_reads/* | grep "1P\.fastq\.gz")
fastq2=$( ls $out_dir/trimmed_reads/* | grep "2P\.fastq\.gz")
alignment_folder=${out_dir}/alignment/bam

script_dir="/home/yup1/dev/cut_n_tag/cut_tag_pipeline_v1"
spike_ref="/media/Data03/public_data/Genome/bowtie2_idx/ecoli"

# #spike-in normalization
scale_factor=$alignment_folder/${sample_name}.scaleFactor
echo "running spike-in" >> ${out_dir}/status.log
bash $script_dir/scaling_factor/align_spike-in_genome.sh $spike_ref $fastq1 $fastq2 $alignment_folder $sample_name $alignment_folder/bowtie2_summary/${sample_name}_spike-in_bowtie2
spikeIn_seq_depth=$(ls $alignment_folder/*.seqDepth | grep "spike-in" )
sample_seq_depth=$( ls $alignment_folder/*.seqDepth | grep -v "spike-in" | head -1)
#Rscript $script_dir/scaling_factor/cal_scaling_factor.R --spike_in_path $spikeIn_seq_depth --out_path $scale_factor
Rscript $script_dir/scaling_factor/cal_scaling_factor_cutana.R --sample_path $sample_seq_depth  --spike_in_path $spikeIn_seq_depth --out_path $scale_factor

#file conversion
bam=$( ls $alignment_folder/* | grep qualityScore | grep "_rmDup" | grep "_sorted_by_name_fixed.bam$")
#bam=$org_bam
echo $bam
bed_folder=${out_dir}/alignment/bed
mkdir -p $bed_folder
echo "$scale_factor"
bash $script_dir/convert_file.sh $bam $bed_folder ${sample_name}_spikein $scale_factor

genome=hg38
peak_folder=${out_dir}/peak_calling/SEACR
sample_bedgraph=$( ls ${bed_folder}/*_bowtie2_fragments_normalized.bedgraph | grep "spikein" |head -1 )
bash $script_dir/run_seacr.sh $sample_bedgraph "$peak_folder/${sample_name}_${genome}_spikein" $ctrl_bedgraph