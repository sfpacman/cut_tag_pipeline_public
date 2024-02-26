#!/usr/bin/env nextflow

/* process parse_config {

} */

process test_cut_tag{
    debug true
    input:
    tuple val(sample_name), val(sample_group_name), val(read1), val(read2),val(rep),val(peak_call)
    val out_dir
    val script_dir
    val ref_dir
    val ctrl_bedgraph
    val ctrl_bam
    shell:
    '''
     bash !{script_dir}/run_test_cut_tag.sh !{read1} !{read2} !{out_dir}/!{sample_name} !{sample_name} !{script_dir} !{ref_dir} FALSE TRUE TRUE !{ctrl_bedgraph} !{ctrl_bam} 
    '''
    
}
 process make_bam_path {
    input:
    tuple val(sample_name), val(sample_group_name), val(read1), val(read2),val(rep),val(peak_call)
    
    output:
    tuple val(sample_name), val(sample_group_name), val(read1), val(read2),val(rep),val(peak_call),val(bam_path)
    
    script:
    bam_regex="${params.out_dir}/sample_folder/sample_folder_sorted_rmDup_qualityScore_2_sorted.bam"
    bam_path = bam_regex.replaceAll(/sample_folder/,sample_name)
    
    '''
    echo "making path"
    '''
} 

process test_idr {
    input:
    tuple val(rep_peak_1) val(rep_peak_2) val(pooled_peak)
    val idr_output_dir
    val script_dir
    shell:
    '''
    bash !{sciript_dir}/test_run_idr.sh !{rep_peak_1} !{rep_peak_2} !{pooled_peak} !{idr_output_dir}
    '''
}
workflow test_cut_tag_main {
    take: 
    meta_data
    params
    main:
    println("this is $params.out_dir")
    if(! params.ctrl_bedgraph) { params.ctrl_bedgraph =""}
    if(! params.ctrl_bam) {params.ctrl_bam=""}
    test_cut_tag(meta_data, params.out_dir, params.main_script_dir, params.ref_dir,params.ctrl_bedgraph,params.ctrl_bam)
}

workflow test_pooled_peak_call {
    take:
    meta_data
    params
    main:

    bam_path = Channel.fromPath(bam_find_regex, checkIfExists:true)
    //bam_path.view()

}

workflow {
 ch_sample_meta = Channel.fromPath(params.samplesheet, checkIfExists:true) \
                  | splitCsv(header:true) \
                  | map{
                     row -> tuple( row.sample_name,row.sample_group_name,row.fastq_1,row.fastq_2,row.rep,row.peak_caller)}

println("this is $projectDir $params.main_script_dir")
//test_cut_tag_main(ch_sample_meta,params) 
bam_file_path = make_bam_path(ch_sample_meta)
test_pooled_peak_call (bam_file_path.groupTuple(by: 1),params)

}