// --- FILE: modules/blast_charts.nf ---
nextflow.enable.dsl=2

process BLAST_CHARTS {

    input:
    // OmicsBox project (.box) with BLAST hits emitted by the upstream DIAMOND_BLAST step.
    path blasted_project

    output:
    path "blast_charts/*.${params.chart_format}", emit: blast_charts

    script:
    def args = task.ext.args ?: ''

    """
    mkdir -p blast_charts
    omicsbox statistics-blast \\
        --i-input-project=\$PWD/${blasted_project.name} \\
        --chart-format=${params.chart_format} \\
        --local-folder=\$PWD/blast_charts \\
        $args
    """
}
