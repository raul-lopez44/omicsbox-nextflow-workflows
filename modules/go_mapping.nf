// --- FILE: modules/go_mapping.nf ---
nextflow.enable.dsl=2

process GO_MAPPING {

    input:
    // OmicsBox BLAST Project (.box) emitted by the upstream DIAMOND_BLAST step.
    path blasted_project

    output:
    path "${task.ext.outdir}/*", emit: mapped_project

    script:
    def outdir = task.ext.outdir ?: task.process.toLowerCase()
    def args = task.ext.args ?: ''

    """
    mkdir -p ${outdir}
    omicsbox mapping-cloud \\
        --i-project=\$PWD/${blasted_project.name} \\
        --local-folder=\$PWD/${outdir} \\
        $args
    """
}
