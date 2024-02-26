# Background 
This Cut and Tag Pipline based on 

[CUT&Tag Data Processing and Analysis Tutorial](https://yezhengstat.github.io/CUTTag_tutorial/index.html) from _Ye_ _Zheng_ _el._ _al.
# Prerequisites

conda is used to mange software used in this pipeline.  For further information, please consult https://docs.anaconda.com/anaconda/install/linux-aarch64/.

Included in this repository is the `conda_env_no_build.yaml` which contains all packages required to install this pipeline.

# Installation

1. Clone the repo
   ```sh
   git clone 
   ```
2. Activate conda environment with RNA_Seq.yml file
   ```sh
   conda env activate -f conda_env_no_build.yaml
   ```
You are now ready to run the pipeline!




# Nextflow 
Under development 

# Bash 

Example bash script can be found in ```example``` folder

## Core
use ```script/main/run_cut_tag.sh``` to run cut and tag pipeline. 

### Input
The script takes the following arguments:

* raw_fastq1
* raw_fastq2
* out_dir
* sample_name
* script_dir
* skip_trimmed
* no_rose2
* no_spikein
* peak_caller ( seacr or macs2 )
* ctrl_bedgraph
* ctrl_bam

```bash 

bash script/main/run_cut_tag.sh $fastq_1 $fastq_2 ${out_dir}/$sample_name $sample_name $script_dir false true $ctrl_bam $ctrl_bedgraph 

```
## Post-processing
### Run QC

```
bash script/post_processing/run_QC.sh script/post_processing/QC $out_dir
```
### Organize all outputs

#### Input
* out_dir: directory where the pipeline output directory is 
* final_result: path where organized data folder should be  
```
bash $script_folder/symlink_final_result.sh $out_dir $final_result
```
## Output
Single sample output
```
Sample_folder
├── alignment
│   ├── bam
│   └── bed
├── fastqc
├── peak_calling
├── QC_summary
└──trimmed_reads
```

Organized data output  
```
final_results
├── bam
├── cpm
├── fastqc
├── frag_legnth
├── Sample_run_frip_score_summary.txt
├── Sample_run_QC_summary.csv
├── peak
└── QC
```

**Note**: all reference files should be downloaded to ref folder
* NEB Ultra II Kit  is obtained from 
https://www.neb.com/faqs/2021/01/15/what-sequences-need-to-be-trimmed-for-nebnext-libraries-that-are-sequenced-on-an-illumina-instrument
(If you use other library prep kit other than NEB, you need to obtain adapter sequence from the vendor)
* Bowtie2 genome ref should be downloaded into ref folder. We use the no alternative set. 
https://bowtie-bio.sourceforge.net/bowtie2/manual.shtml#indexing-a-reference-genome
* E. coli genome ref should be downloaded into ref folder if you use E. coli spike-in 

## Pooled Peak calling
Inspired by ChIP-seq ENCODE 3 pipeline, replicated BAM files are combined for peak calling using MACS2. IDR is then applied to assess the reproducibility of the pooled peak sets. 

### Run MACS2
The script takes the following arguments:
* out_sample : output sample name with path (e.g. out_folder/Sample1_pooled) 
* control_bam
* sample_repX_bam : bam files for reach replicates 


```bash
bash script/pooled_sample_processing/pooled_run_macs2.sh $out_sample $control_bam $sample_rep1_bam $sample_repX_bam 
```
### Run IDR
The script accept only two replicates peak sets and run by using the following argument. 

* rep1
* rep2
* pool_peak
* Idr_output_folder


```bash
bash script/pooled_sample_processing/run_idr.sh $rep1 $rep2 $pooled_peak $idr_output
```





