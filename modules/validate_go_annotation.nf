// --- FILE: modules/validate_go_annotation.nf ---
nextflow.enable.dsl=2

process VALIDATE_GO_ANNOTATION {

    input:
    // Final consolidated OmicsBox project (.box) emitted by the upstream MERGE_EGGNOG_5_GOS step.
    path final_project

    output:
    path "validate_go_annotation/*.box", emit: validated_project

    script:
    def args = task.ext.args ?: ''

    """
    mkdir -p validate_go_annotation
    omicsbox validate-annotation \\
        --i-project=\$PWD/${final_project.name} \\
        --local-folder=\$PWD/validate_go_annotation \\
        $args
    """
}
