// --- FILE: modules/project_charts.nf ---
nextflow.enable.dsl=2

process PROJECT_CHARTS {

    input:
    // Validated OmicsBox project (.box) emitted by the upstream VALIDATE_GO_ANNOTATION step.
    path validated_project

    output:
    path "project_charts/*.${params.chart_format}", emit: project_charts

    script:
    def args = task.ext.args ?: ''

    """
    mkdir -p project_charts
    omicsbox statistics-project \\
        --i-project=\$PWD/${validated_project.name} \\
        --chart-format=${params.chart_format} \\
        --local-folder=\$PWD/project_charts \\
        $args
    """
}
