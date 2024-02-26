#!/bin/bash
set -e
set -u

script_dir=$1
root_result_folder=$2

for folder in $( ls -d  $root_result_folder/*/ | egrep -v "final_result.?|multiqc_data" );do 
    raw_bam=$(  ls $folder/alignment/bam/*| grep "_hg38_bowtie2.bam$")
    out_frag=$( basename $raw_bam | sed 's/.bam//g' )_fragmentLen.txt
    bash $script_dir/get_fragmentLen.sh $raw_bam  $folder/alignment/bam/$out_frag
    fragmentLen_list_path=$folder/alignment/bam/*_fragmentLen.txt
    picard_log_path=$folder/alignment/bam/picard_summary/*_picard_rmDup.txt
    bowtie2_log_path=$folder/alignment/bam/bowtie2_summary/*_bowtie2.log
    #bowtie2_log_path=$folder/alignment/bam/*_bowtie2.log
    bowtie2_spikein_log_path=$folder/*_spike-in_bowtie2.log
    scale_factor_path=$folder/alignment/bam/*.scaleFactor
    sample=$(basename $folder)
    mkdir -p $folder/QC_summary
    output_file=$folder/QC_summary/${sample}_qc_summary.csv
    bam=$( ls $folder/alignment/bam/*| grep qualityScore | grep "_rmDup" | grep "_sorted_by_name_fixed.bam$")
    echo "calculate frip score"

    for peak in $( ls $folder/peak_calling/macs2/* | egrep ".stringent.bed$|.narrowPeak$");do
        if [-s $peak ] ;then
        out_dir=$(dirname $peak )
        peak_name=$( basename $peak )
        echo "$out_dir/${peak_name}.frip"
        Rscript $script_dir/cal_frip.R --bam $bam --peak $peak --out $out_dir/${peak_name}.frip
        else
          echo "$peak has zero size"
        fi    
    done
    echo "Running parse_QC_summary.R for $sample"
    Rscript $script_dir/parse_QC_summary.R --frip_path $out_dir/${peak_name}.frip  --scale_factor $scale_factor_path --fragmentLen_list_path $fragmentLen_list_path --picard_log_path $picard_log_path --bowtie2_log_path $bowtie2_log_path --sample $sample --output_file $output_file
    
done
