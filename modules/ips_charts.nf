// --- FILE: modules/ips_charts.nf ---
nextflow.enable.dsl=2

process IPS_CHARTS {

    input:
    // OmicsBox IPS Project (.box) emitted by the upstream INTERPROSCAN step.
    path ips_project

    output:
    path "ips_charts/*.${params.chart_format}", emit: ips_charts

    script:
    def args = task.ext.args ?: ''

    """
    mkdir -p ips_charts
    omicsbox statistics-interpro \\
        --i-project=\$PWD/${ips_project.name} \\
        --chart-format=${params.chart_format} \\
        --local-folder=\$PWD/ips_charts \\
        $args
    """
}
