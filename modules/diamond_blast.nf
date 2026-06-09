// --- FILE: modules/diamond_blast.nf ---
nextflow.enable.dsl=2

process DIAMOND_BLAST {

    input:
    // OmicsBox Sequence Project (.box) emitted by the upstream LOAD_FASTA step.
    path omicsbox_project

    output:
    path "${task.ext.outdir}/*", emit: blasted_project

    script:
    def outdir = task.ext.outdir ?: task.process.toLowerCase()
    def args = task.ext.args ?: ''
    def cloud_flag = params.cloud_folder ? "--cloud-folder=${params.cloud_folder}" : ""

    """
    mkdir -p ${outdir}
    omicsbox diamond \\
        --i-input-project=\$PWD/${omicsbox_project.name} \\
        --local-folder=\$PWD/${outdir} \\
        $cloud_flag \\
        $args
    """
}
