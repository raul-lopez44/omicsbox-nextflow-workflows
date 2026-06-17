// --- FILE: modules/ips.nf ---
nextflow.enable.dsl=2

process INTERPROSCAN {

    input:
    // OmicsBox Sequence Project (.box) emitted by the upstream LOAD_FASTA step.
    path omicsbox_project

    output:
    path "${task.ext.outdir}/*.box", emit: ips_project
    path "${task.ext.outdir}/*.{xml,json,gff3,tsv}", emit: export_files, optional: true

    script:
    def outdir = task.ext.outdir ?: task.process.toLowerCase()
    def args = task.ext.args ?: ''
    def cloud_flag = params.cloud_folder ? "--cloud-folder=${params.cloud_folder}" : ""

    """
    mkdir -p ${outdir}
    omicsbox ips \\
        --i-local-project=\$PWD/${omicsbox_project} \\
        --local-folder=\$PWD/${outdir} \\
        $cloud_flag \\
        $args
    """
}
