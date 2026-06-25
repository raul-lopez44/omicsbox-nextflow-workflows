// --- FILE: modules/metagenomics/pfam_scan.nf ---
// Wraps: omicsbox pfam-scan  |  backend: WJOB_ASYNC
// Annotates protein sequences with Pfam domains.
nextflow.enable.dsl=2

process PFAM_SCAN {

    input:
    path proteins               // Predicted proteins FASTA (from Prodigal)

    output:
    path "${task.ext.outdir}/*report*.box", emit: report              // OmicsBox report
    path "${task.ext.outdir}/*", emit: pfam_output                    // Pfam annotation files

    script:
    def outdir = task.ext.outdir ?: task.process.toLowerCase()
    def args = task.ext.args ?: ''

    // WJOB_ASYNC
    def cloud_flag = params.cloud_folder ? "--cloud-folder=${params.cloud_folder}" : ""

    """
    mkdir -p ${outdir}
    xvfb-run -a omicsbox pfam-scan \\
        --i-input-sequences=\$PWD/${proteins} \\
        --local-folder=\$PWD/${outdir} \\
        ${cloud_flag} \\
        ${args}
    """
}
