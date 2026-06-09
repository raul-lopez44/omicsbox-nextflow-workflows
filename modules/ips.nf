// --- FILE: modules/ips.nf ---
nextflow.enable.dsl=2

process INTERPROSCAN {

    input:
    // OmicsBox Sequence Project (.box) emitted by the upstream LOAD_FASTA step.
    path omicsbox_project

    output:
    path "${task.ext.outdir}/*", emit: ips_project

    script:
    def outdir = task.ext.outdir ?: task.process.toLowerCase()
    def args = task.ext.args ?: ''
    def cloud_flag = params.cloud_folder ? "--cloud-folder=${params.cloud_folder}" : ""

    """
    mkdir -p ${outdir}
    omicsbox ips \\
        --i-input-project=\$PWD/${omicsbox_project.name} \\
        --local-folder=\$PWD/${outdir} \\
        $cloud_flag \\
        $args
    """
}
