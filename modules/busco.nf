// --- FILE: modules/busco.nf ---
// Wraps: omicsbox busco  |  backend: WJOB_ASYNC
// Assesses assembly completeness against a BUSCO lineage database.
// Terminal step in the clustering branch — outputs are not connected further.
nextflow.enable.dsl=2

process BUSCO {

    input:
    path sequences   // Clustered FASTA from CDHIT

    output:
    path "${task.ext.outdir}/*.box", emit: busco_results

    script:
    def outdir     = task.ext.outdir ?: task.process.toLowerCase()
    def args       = task.ext.args   ?: ''

    // WJOB_ASYNC
    def cloud_flag = params.cloud_folder ? "--cloud-folder=${params.cloud_folder}" : ""

    """
    mkdir -p ${outdir}
    omicsbox busco \\
        --i-sequences=\$PWD/${sequences} \\
        --local-folder=\$PWD/${outdir} \\
        ${cloud_flag} \\
        ${args}
    """
}
