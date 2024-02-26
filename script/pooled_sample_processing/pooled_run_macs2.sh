#!/bin/bash
set -e
set -u 

out_sample=$1
control_bam=$2
out_dir=$(dirname $out_sample)
sample_name=$( basename $out_sample)_pooled
shift 2
sample_bam=$@


mkdir -p $out_dir

if ! [ -z $control_bam  ];then
		echo "Running pooled peak calling mode"
		macs2 callpeak -t ${sample_bam} -c ${control_bam} -n ${out_dir}/${sample_name} -g hs -p 1e-3 --nomodel -f BAMPE --keep-dup all -B --SPMR &2>  $out_dir/macs2Peak_summary.txt
		sort -k8,8nr ${out_dir}/${sample_name}_peaks.narrowPeak > ${out_dir}/${sample_name}_sorted_peaks.narrowPeak
	else
		macs2 callpeak -t $sample_bam -p 1e-10 -f BAMPE --keep-dup all -n ${sample_name}_v3 --outdir $out_dir  2>> $out_dir/macs2Peak_summary.txt
	fi
fi

