#!/bin/bash
set -e
set -u 

sample_bam=$1
sample=$2
control_bam=$3
is_tf=$4
#fragment_length=$5


out_dir=$( dirname $sample )
sample_name=$( basename $sample )

mkdir -p $out_dir

if ! [ -z $control_bam  ];then
	# macs2 callpeak -t $sample_bam \
	#       -c $control_bam \
	#       -g hs -f BAMPE -n ${sample_name}_v2 --outdir $out_dir -q 0.1 --keep-dup all 2> $out_dir/macs2Peak_summary.txt
	if $is_tf;then
		echo "Running TF mode"
		if [ $control_bam == false ] ; then 
	    macs2 callpeak -t ${sample_bam} -n ${out_dir}/${sample_name}_no_ctrl -g hs -p 1e-3 --nomodel -f BAMPE --keep-dup all -B --SPMR &2>  $out_dir/macs2Peak_summary.txt
		#doesn't work - need fixing
		sort -k8,8nr ${out_dir}/${sample_name}_peaks.narrowPeak > ${out_dir}/${sample_name}_sorted_peaks.narrowPeak
		#rm  ${out_dir}/${sample_name}_peaks.narrowPeak
	  else  
	    macs2 callpeak -t ${sample_bam} -c ${control_bam} -n ${out_dir}/${sample_name} -g hs -p 1e-3 --nomodel -f BAMPE --keep-dup all -B --SPMR &2>  $out_dir/macs2Peak_summary.txt
	  fi
	else
		macs2 callpeak -t $sample_bam -p 1e-10 -f BAMPE --keep-dup all -n ${sample_name}_v3 --outdir $out_dir  2>> $out_dir/macs2Peak_summary.txt
	fi

fi
