// --- FILE: modules/ec_code_mapping.nf ---
nextflow.enable.dsl=2

process EC_CODE_MAPPING {

    input:
    // Validated OmicsBox project (.box) emitted by the upstream VALIDATE_GO_ANNOTATION step.
    path validated_project

    output:
    path "ec_code_mapping/*.box", emit: ec_mapped_project

    script:
    def args = task.ext.args ?: ''

    """
    mkdir -p ec_code_mapping
    omicsbox enzymecode-run \\
        --i-project=\$PWD/${validated_project.name} \\
        --local-folder=\$PWD/ec_code_mapping \\
        $args
    """
}
