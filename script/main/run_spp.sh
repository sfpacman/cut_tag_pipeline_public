#run_spp.R obtained from conda env ENCODE ChIP-seq pipline - mostly likely originated from phantompeakqualtools
set -e 
set -u

script_dir=$1
bam=$2
sample=$3
input_control_bam=$4
node=$5
fdr="1e-2"

out_dir=$( dirname $sample )
sample_name=$( basename $sample )

mkdir -p $out_dir

#echo "Rscript $script_dir/run_spp.R -p=$node -c=$bam -i=$input_control_bam -npeak=300000 -odir=$out_dir  -savn=${sample}_ssp.narrowPeak -fdr=$fdr -savp=${sample}_ssp_plot.pdf  -rf 2>> $out_dir/spp_Peak_summary.txt"
Rscript $script_dir/run_spp.R -p=$node -c=$bam -i=$input_control_bam -npeak=300000 -odir=$out_dir  -savn=${sample}_ssp.narrowPeak -fdr=$fdr -savp=${sample}_ssp_plot.pdf  -rf 2>> $out_dir/spp_Peak_summary.txt

#Rscript $script_dir/run_spp.R -p=$node -c=$bam -i=$input_control_bam -odir=$out_dir -savn=${sample}_ssp.narrowPeak -fdr=$fdr -savp=${sample}_ssp_plot.pdf -rf 2>> $out_dir/spp_Peak_summary.txt