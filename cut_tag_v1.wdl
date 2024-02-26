version 1.0

workflow cut_and_tag{
    input{
        String pipeline_ver = 'v0.0.0'
        String script_path
        File raw_fastq_1
        File raw_fastq_2
        File ref_seq
        String sample_name
    }
}

task trim_adapter{
    input {
        File raw_fastq_1
        File raw_fastq_2
        String
    }

}

task align_read {
    input{
        File fastq_1
        File fastq_2
        File ref_fastq
        String script_path
        String out_dir = "alignment/bam"
        String sample_name
        String out_summary = "bowtie2_out"
    }
  command {
      bash ~{script_path}/run_bowtie2.sh ~{ref_fastq} ~{fastq_1} ~{fastq_2} ~{out_dir} ~{sample_name} ~{out_summary}
  }
}




