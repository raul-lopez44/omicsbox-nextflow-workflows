// --- FILE: modules/statistics_blast.nf ---
nextflow.enable.dsl=2

process STATISTICS_BLAST {

    input:
    // OmicsBox project (.box) with BLAST hits emitted by the upstream DIAMOND_BLAST step.
    path blasted_project

    output:
    path "*.box", emit: blast_charts

    script:
    def args = task.ext.args ?: ''

    """
    # Generate BLAST statistics charts from an OmicsBox BLAST project
    omicsbox statistics-blast \\
        --i-project=${blasted_project} \\
        --o-blast-statistics-chart=${blasted_project.baseName}_chart.box \\
        $args
    """
}
