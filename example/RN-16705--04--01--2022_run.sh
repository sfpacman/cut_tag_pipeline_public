#!/bin/bash
#set -e
source /home/yup1/miniconda3/etc/profile.d/conda.sh
conda activate ngs
script_folder=$1
run_ct_script=$script_folder/run_cut_tag.sh
fastq_dir=$2
out_dir=$3

mkdir -p $out_dir

# run ctrl first
ctrl_fastq_folder=$( ls $fastq_dir/*IgG* | sed 's/_S[0-9]\+_R[1-2]_00[0-9].fastq.gz//g'| uniq )

for ctrl_fastq in $ctrl_fastq_folder ;do
    ctrl_fastq_1=$(ls ${ctrl_fastq}* | grep "_R1_")
    ctrl_fastq_2=$(ls ${ctrl_fastq}* | grep "_R2_")
    sample_name=$( basename $ctrl_fastq)
    echo $sample_name >> $$.tmp
    #echo $ctrl_fastq_2
    #nohup bash $run_ct_script $ctrl_fastq_1 $ctrl_fastq_2 ${out_dir}/$sample_name $sample_name false true &

done
#echo $ctrl_fastq_folder > $$.tmp
cat $$.tmp
#wc -l $$.tmp
#exit 0
# run sample first 

fastq_folder=$( ls $fastq_dir/* | grep -v "IgG" | sed 's/_S[0-9]\+_R[1-2]_00[0-9].fastq.gz//g'| uniq  )

for fastq in $fastq_folder; do
    echo "running sample"
    fastq_1=$(ls ${fastq}* | grep "_R1_")
    fastq_2=$(ls ${fastq}* | grep "_R2_")
    sample_name=$( basename $fastq)
    # The regex needs to be changed
    sample_base_name=$( echo $sample_name | grep -Eo "^CR-202[0-9]" )
    ctrl_name=$(  grep -i $sample_base_name  $$.tmp )
    echo "$ctrl_name"
    ctrl_bam=$( ls  -d $out_dir/$ctrl_name/alignment/bam/*  | grep "_sorted_by_name_fixed.bam$" )
    ctrl_bedgraph=$( ls -d $out_dir/$ctrl_name/alignment/bed/* | grep "_bowtie2_fragments_normalized.bedgraph" )
    nohup bash $run_ct_script $fastq_1 $fastq_2 ${out_dir}/$sample_name $sample_name false true $ctrl_bam $ctrl_bedgraph& 
done

rm $$.tmp

# final_result=$out_dir/final_results
#bash $script_folder/run_QC.sh $script_folde/QC $out_dir
#bash $script_folder/symlink_final_result.sh $out_dir $final_result
# for result in $( ls -d  $out_dir/*/);do
#     sample=$( basename $result)
#     bash $script_folder/symlink_final_result.sh $result $final_result/$sample
# done

