// --- FILE: modules/go_mapping.nf ---
nextflow.enable.dsl=2

process GO_MAPPING {

    input:
    // OmicsBox BLAST Project (.box) emitted by the upstream DIAMOND_BLAST step.
    path blasted_project

    output:
    path "go_mapping/*.box", emit: mapped_project

    script:
    def args = task.ext.args ?: ''

    """
    mkdir -p go_mapping
    omicsbox mapping-cloud \\
        --i-input-project=\$PWD/${blasted_project.name} \\
        --local-folder=\$PWD/go_mapping \\
        $args
    """
}
