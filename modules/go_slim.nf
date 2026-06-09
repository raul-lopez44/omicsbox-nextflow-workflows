// --- FILE: modules/go_slim.nf ---
nextflow.enable.dsl=2

process GO_SLIM {

    input:
    // OmicsBox EC-mapped project (.box) emitted by the upstream EC_CODE_MAPPING step.
    path project_file

    output:
    path "go_slim/*.box", emit: goslim_project

    script:
    def args = task.ext.args ?: ''

    """
    mkdir -p go_slim
    omicsbox goslim \\
        --i-project=\$PWD/${project_file.name} \\
        --local-folder=\$PWD/go_slim \\
        $args
    """
}
