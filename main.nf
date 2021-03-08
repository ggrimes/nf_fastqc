
/*
 * pipeline input parameters
 */
params.reads = "$baseDir/*_{1,2}.fq"
params.outdir = "results"
params.fastqcpus = 2

println """\
          FASTQC   P I P E L I N E
         ===================================
         reads        : ${params.reads}
         outdir       : ${params.outdir}
         fastqcpus    : ${params.fastqcpus}
         """
         .stripIndent()

read_ch = Channel.fromFilePairs( params.reads, checkIfExists: true )


process fastqc {
    tag "FASTQC on $sample_id"
    cpus params.fastqcpus

    input:
    tuple sample_id, path(reads) from read_ch

    output:
    path "fastqc_${sample_id}_logs" into fastqc_ch


    script:
    """
    mkdir fastqc_${sample_id}_logs
    fastqc -o fastqc_${sample_id}_logs -t ${task.cpus} -f fastq -q ${reads}
    """
}




/*
* Collect the results from the fastqc processes and run multiqc
* The collect operator collects all the items emitted by a channel to a List and return the resulting object as a sole emission.
*/
process multiqc {
    publishDir params.outdir, mode:'copy'

    input:
    path '*' from fastqc_ch.collect()

    output:
    path 'multiqc_report.html'

    script:
    """
    multiqc .
    """
}
