// --- FILE: modules/export_genesets.nf ---
nextflow.enable.dsl=2

process EXPORT_GENE_SETS {

    input:
    // OmicsBox EC-mapped project (.box) emitted by the upstream EC_CODE_MAPPING step.
    path project_file

    output:
    path "export_genesets/*", emit: genesets_file

    script:
    def args = task.ext.args ?: ''

    """
    mkdir -p export_genesets
    omicsbox export-genesets \\
        --i-project=\$PWD/${project_file.name} \\
        --o-file=\$PWD/export_genesets/gene_sets.txt \\
        $args
    """
}
