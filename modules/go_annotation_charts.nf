// --- FILE: modules/go_annotation_charts.nf ---
nextflow.enable.dsl=2

process GO_ANNOTATION_CHARTS {

    input:
    // OmicsBox Annotated Project (.box) emitted by the upstream GO_ANNOTATION step.
    path annotated_project

    output:
    path "go_annotation_charts/*.${params.chart_format}", emit: annotation_charts

    script:
    def args = task.ext.args ?: ''

    """
    mkdir -p go_annotation_charts
    omicsbox statistics-annotation \\
        --i-input-project=\$PWD/${annotated_project.name} \\
        --chart-format=${params.chart_format} \\
        --local-folder=\$PWD/go_annotation_charts \\
        $args
    """
}
