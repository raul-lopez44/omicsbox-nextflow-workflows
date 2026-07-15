// --- FILE: modules/blast_charts.nf ---
// Wraps: omicsbox statistics-blast
// Generates visualization charts for DIAMOND BLAST results

process BLAST_CHARTS {

    input:
    // OmicsBox project (.box) with BLAST hits emitted by the upstream DIAMOND_BLAST step.
    path blasted_project

    output:
    path "${task.ext.outdir}/e-value-distribution.${params.chart_format}", emit: evalue_chart          // E-value distribution chart
    path "${task.ext.outdir}/top-hit-species-distribution.${params.chart_format}", emit: species_chart  // Top-hit species distribution chart

    script:
    def outdir = task.ext.outdir ?: task.process.toLowerCase()
    def args = task.ext.args ?: ''

    """
    mkdir -p ${outdir}
    omicsbox statistics-blast \\
        --i-project=\$PWD/${blasted_project} \\
        --chart-format=${params.chart_format} \\
        --local-folder=\$PWD/${outdir} \\
        ${args}
    """
}
