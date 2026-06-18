// --- FILE: modules/go_annotation.nf ---
nextflow.enable.dsl=2

process GO_ANNOTATION {

    input:
    // OmicsBox GO Mapped Project (.box) emitted by the upstream GO_MAPPING step.
    path mapped_project

    output:
    path "${task.ext.outdir}/*", emit: annotated_project

    script:
    def outdir = task.ext.outdir ?: task.process.toLowerCase()
    def args = task.ext.args ?: ''

    """
    mkdir -p ${outdir}
    omicsbox annotation-run \\
        --i-project=${mapped_project} \\
        --local-folder=\$PWD/${outdir} \\
        ${args}
    """
}
