// --- FILE: modules/go_mapping_charts.nf ---
nextflow.enable.dsl=2

process GO_MAPPING_CHARTS {

    input:
    // OmicsBox GO Mapped Project (.box) emitted by the upstream GO_MAPPING step.
    path mapped_project

    output:
    path "go_mapping_charts/*.${params.chart_format}", emit: mapping_charts

    script:
    def args = task.ext.args ?: ''

    """
    mkdir -p go_mapping_charts
    omicsbox statistics-mapping \\
        --i-project=\$PWD/${mapped_project.name} \\
        --chart-format=${params.chart_format} \\
        --local-folder=\$PWD/go_mapping_charts \\
        $args
    """
}
