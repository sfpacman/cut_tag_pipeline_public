#!/bin/bash
set -e 
set -u

sample_bed=$1
sample=$2
control_bed=$3

seacr=$( which SEACR_1.3.sh )


echo "bash $seacr $sample_bed 0.01 non stringent ${sample}_seacr_top0.01.peak"
bash $seacr $sample_bed 0.01 non stringent ${sample}_seacr_top0.01.peak
#sleep 3m 
if ! [ -z $control_bed  ];then
	echo "skipping SEACR control"
	#bash $seacr $sample_bed $control_bed non stringent ${sample}_seacr_ctrl.peak
fi

#bash $seacr $projPath/alignment/bedgraph/${histName}_bowtie2.fragments.normalized.bedgraph \
#     $projPath/alignment/bedgraph/${histControl}_bowtie2.fragments.normalized.bedgraph \
#     non stringent $projPath/peakCalling/SEACR/${histName}_seacr_control.peaks
