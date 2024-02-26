#!/usr/bin/env bash
set -e
set -u

raw_fastq1=$1
raw_fastq2=$2
out_dir=$3
sample_name=$4
script_dir=$5
ref_dir=$6
skip_trimmed=$7
no_rose2=$8
no_spikein=$9
peak_caller=$10
ctrl_bedgraph=$11
ctrl_bam=$12


#make directories for each tasks
mkdir -p ${out_dir}/fastqc
mkdir -p ${out_dir}/alignment/bam/bowtie2_summary
mkdir -p ${out_dir}/peak_calling

cd $out_dir
#running fastqc
fastqc_out=${out_dir}/fastqc
mkdir -p $fastqc_out
bash $script_dir/run_fastqc.sh  $fastqc_out $raw_fastq1
bash $script_dir/run_fastqc.sh  $fastqc_out $raw_fastq2

# #running trimmomatic
# NEB Ultra II Kit  is obtained from 
#https://www.neb.com/faqs/2021/01/15/what-sequences-need-to-be-trimmed-for-nebnext-libraries-that-are-sequenced-on-an-illumina-instrument
adapters=$script_dir/ref/trimmomatic/adapters/NEBNext-PE.fa
if $skip_trimmed;then
  fastq1=$raw_fastq1
  fastq2=$raw_fastq2
else
  bash $script_dir/run_trimmomatic.sh $raw_fastq1 $raw_fastq2 $sample_name $adapters
  fastq1=$( ls $out_dir/trimmed_reads/* | grep "1P\.fastq\.gz")
  fastq2=$( ls $out_dir/trimmed_reads/* | grep "2P\.fastq\.gz")
fi

# #running bowtie2 alignment
 echo "running alignment" 
 alignment_folder=${out_dir}/alignment/bam
 ref=$ref_dir/bowtie2_idx/GRCh38_no_alt_analysis_set_GCA_000001405.15.fasta
 # if target_ref_bed is not made, you can run the awk scripts 
 #awk '/^chr[0-9,X,Y]*\t/ {printf("%s\t0\t%s\n",$1,$3);}' ref/bowtie2_idx/GRCh38_no_alt_analysis_set_GCA_000001405.15.fasta.bed > /media/Data03/public_data/Genome/bowtie2_idx/GRCh38_no_alt_chrom.bed
 target_ref_bed=$ref_dir/bowtie2_idx/GRCh38_no_alt_chrom.bed
 [  -e  $target_ref_bef ] || exit 1
#echo "$script_dir/align_genome.sh $ref $fastq1 $fastq2 $alignment_folder $sample_name ${sample_name}_bowtie2"
bash $script_dir/align_genome.sh $ref $target_ref_bed $fastq1 $fastq2 $alignment_folder $sample_name $alignment_folder/bowtie2_summary/${sample_name}_bowtie2

#run picard depuplicate
#ls $alignment_folder/${sample_name}_hg38_bowtie2.bam
[ -e $alignment_folder/${sample_name}_hg38_bowtie2.bam ] || exit 1
out_picard_dir=$alignment_folder
bam=$( ls $alignment_folder/* | grep ${sample_name}_hg38_bowtie2.bam )
#org_bam=$bam
bash $script_dir/run_picard_duplicates.sh $out_picard_dir $bam $sample_name
sort_bam=$( ls $alignment_folder/* | grep ${sample_name}_hg38_bowtie2_sorted.bam$ )
[ -e $sort_bam ] || exit 1
cpm=$( echo $sort_bam | sed 's/\.bam$/_CPM.bw/g' )
echo "making bigWig"
bash $script_dir/get_CPM.sh $sort_bam $cpm

#filtering bam
out_filter_dir=$alignment_folder
bam=$( ls $alignment_folder/* | grep ${sample_name}_hg38 | grep "_rmDup.bam" )
echo $bam
#bam=$org_bam
# subjected for remove
bash $script_dir/filter_bam.sh $bam $out_filter_dir

#spike-in normalization
scale_factor=$alignment_folder/${sample_name}.scaleFactor
if $no_spikein ;then
  echo "1" > $scale_factor
else
  echo "running spike-in" >> ${out_dir}/status.log
  spike_ref=$script_dir/ref/bowtie2_idx/ecoli
  bash $script_dir/scaling_factor/align_spike-in_genome.sh $spike_ref $fastq1 $fastq2 $alignment_folder $sample_name $alignment_folder/bowtie2_summary/${sample_name}_spike-in_bowtie2
  spikeIn_seq_depth=$(ls $alignment_folder/*.seqDepth | grep "spike-in" )
  sample_seq_depth=$( ls $alignment_folder/*.seqDepth | grep -v "spike-in" | head -1)
  ls "$seq_depth"
  #Rscript $script_dir/scaling_factor/cal_scaling_factor.R --spike_in_path $spikeIn_seq_depth --out_path $scale_factor
  Rscript $script_dir/scaling_factor/cal_scaling_factor_cutana.R --sample_path $sample_seq_depth  --spike_in_path $spikeIn_seq_depth --out_path $scale_factor
fi
#file conversion
bam=$( ls $alignment_folder/* | grep qualityScore | grep "_rmDup" | grep "_sorted_by_name_fixed.bam$")
#bam=$org_bam
bed_folder=${out_dir}/alignment/bed
mkdir -p $bed_folder
echo "$scale_factor"
chrom_size=$script_dir/ref/hg38.chrom.sizes
bash $script_dir/convert_file.sh $bam $bed_folder $sample_name $scale_factor $chrom_size

#assuming output of convert_file.sh is *_bowtie2_fragments_normalized.bedgraph 
if [[ $peak_caller == "seacr" ]]; then
    #run_seacr
    genome=hg38
    peak_folder=${out_dir}/peak_calling/SEACR
    mkdir -p $peak_folder
    sample_bedgraph=$( ls ${bed_folder}/*_bowtie2_fragments_normalized.bedgraph | head -1 )
    bash $script_dir/run_seacr.sh $sample_bedgraph $peak_folder/${sample_name}_$genome $ctrl_bedgraph
  elif [[ $peak_caller == "macs2" ]] ;then
    #run_macs2
    peak_folder=${out_dir}/peak_calling/macs2
    mkdir -p $peak_folder
    bash $script_dir/run_macs2.sh $bam $peak_folder/${sample_name}_$genome $ctrl_bam
  else
      echo "please select either macs2 or seacr" && exit 0
  fi

sleep 30s 
#run ROSE2
peak_folder=${out_dir}/peak_calling/ROSE2
SEACR_peaks=$( ls ${out_dir}/peak_calling/SEACR/*.peak.stringent.bed )

for peak in $SEACR_peaks;do
bam=$( ls $alignment_folder/* | grep qualityScore | grep "_rmDup" | grep "_sorted.bam$")
echo $peak $bam
  bash $script_dir/run_rose2.sh $bam $peak $peak_folder
done 













