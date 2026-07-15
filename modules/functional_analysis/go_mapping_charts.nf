// --- FILE: modules/go_mapping_charts.nf ---
// Wraps: omicsbox statistics-mapping
// Generates GO mapping distribution charts

process GO_MAPPING_CHARTS {

    input:
    // OmicsBox GO Mapped Project (.box) emitted by the upstream GO_MAPPING step.
    path mapped_project

    output:
    path "${task.ext.outdir}/evidence-code-distribution-for-sequences.${params.chart_format}", emit: evidence_chart  // Evidence-code distribution chart
    path "${task.ext.outdir}/go-mapping-distribution.${params.chart_format}", emit: mapping_chart                    // GO-mapping distribution chart

    script:
    def outdir = task.ext.outdir ?: task.process.toLowerCase()
    def args = task.ext.args ?: ''

    """
    mkdir -p ${outdir}
    omicsbox statistics-mapping \\
        --i-project=\$PWD/${mapped_project} \\
        --chart-format=${params.chart_format} \\
        --local-folder=\$PWD/${outdir} \\
        ${args}
    """
}
