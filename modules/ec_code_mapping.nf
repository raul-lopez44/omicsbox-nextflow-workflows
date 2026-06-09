// --- FILE: modules/ec_code_mapping.nf ---
nextflow.enable.dsl=2

process EC_CODE_MAPPING {

    input:
    // Validated OmicsBox project (.box) emitted by the upstream VALIDATE_GO_ANNOTATION step.
    path validated_project

    output:
    path "${task.ext.outdir}/*", emit: ec_mapped_project

    script:
    def outdir = task.ext.outdir ?: task.process.toLowerCase()
    def args = task.ext.args ?: ''

    """
    mkdir -p ${outdir}
    omicsbox enzymecode-run \\
        --i-project=\$PWD/${validated_project.name} \\
        --local-folder=\$PWD/${outdir} \\
        $args
    """
}
