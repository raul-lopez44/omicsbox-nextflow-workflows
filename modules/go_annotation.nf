// --- FILE: modules/go_annotation.nf ---
nextflow.enable.dsl=2

process GO_ANNOTATION {

    input:
    // OmicsBox GO Mapped Project (.box) emitted by the upstream GO_MAPPING step.
    path mapped_project

    output:
    path "go_annotation/*.box", emit: annotated_project

    script:
    def args = task.ext.args ?: ''

    """
    mkdir -p go_annotation
    omicsbox annotation-run \\
        --i-project=\$PWD/${mapped_project.name} \\
        --local-folder=\$PWD/go_annotation \\
        $args
    """
}
