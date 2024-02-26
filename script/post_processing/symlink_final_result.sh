#!/bin/bash
set -e
set -u

root_result_folder=$1
final_result_folder=$2
root_result_folder_name=$( basename $root_result_folder )
cd $root_result_folder

mkdir -p $final_result_folder/bam
mkdir -p $final_result_folder/cpm
mkdir -p $final_result_folder/peak
mkdir -p $final_result_folder/QC
mkdir -p $final_result_folder/fastqc
mkdir -p $final_result_folder/frag_legnth

#Linking bam files
for i in $( ls $root_result_folder/*/alignment/bam/*.bam | grep "qualityScore_[0-9]_sorted.bam");do
    bam=$( basename $i)
    ln -rs $i $final_result_folder/bam/$bam
    ln -rs ${i}.bai $final_result_folder/bam/${bam}.bai
done

for i in $( ls $root_result_folder/*/alignment/bam/*_fragmentLen.txt);do
    frag=$( basename $i)
    ln -rs $i $final_result_folder/frag_legnth/$frag
done

for i in $( ls $root_result_folder/*/alignment/bam/*_CPM.bw );do
    cpm=$(basename $i)
    ln -rs $i $final_result_folder/cpm/$cpm
done

for peak_folder in $( ls -d $root_result_folder/*/peak_calling/*);do 
    peak_type=$( basename $peak_folder )
    peak_sub_folder=$final_result_folder/peak/$peak_type
    mkdir -p $peak_sub_folder
    for peak in $( ls $peak_folder/* | grep -v "_summary.txt");do
        peak_file=$( basename $peak )        
        ln -rs $peak $peak_sub_folder/$peak_file
    done
done

#making QC metrics
#linking fastqc metrics
for i in $( ls $root_result_folder/*/fastqc/*.html);do
    fastqc_html=$( basename $i )
    ln -rs $i $final_result_folder/fastqc/$fastqc_html
done

#bowtie 2 summary 
mkdir -p $final_result_folder/QC/bowtie2/ 

for raw_bowtie_summary in $( ls -d $root_result_folder/*/alignment/bam/bowtie2_summary/*_bowtie2.log );do
    #sample_name=$( dirname $raw_bowtie_summary | sed "s@$root_result_folder/@@g" | grep -Eo "^[^/]+")
    bowtie2_log=$(basename $raw_bowtie_summary)
    ln -rs $raw_bowtie_summary $final_result_folder/QC/bowtie2/$bowtie2_log

done

#picard summary
mkdir -p $final_result_folder/QC/picard
for raw_picard_summary in $( ls -d $root_result_folder/*/alignment/bam/picard_summary/*.txt | grep "picard");do
    picard_log=$( basename $raw_picard_summary )
    ln -rs $raw_picard_summary $final_result_folder/QC/picard/$picard_log
done

awk '{if (FNR==NR){print $0} else if(FNR >1){print $0 }}' $root_result_folder/*/QC_summary/*csv > $final_result_folder/${root_result_folder_name}_QC_summary.csv
cat  $root_result_folder/*/peak_calling/*/*.frip > $final_result_folder/${root_result_folder_name}_frip_score_summary.txt