// --- FILE: modules/ips_charts.nf ---
// Wraps: omicsbox statistics-interpro
// Generates InterProScan domain distribution charts

process IPS_CHARTS {

    input:
    // OmicsBox IPS Project (.box) emitted by the upstream INTERPROSCAN step.
    path ips_project

    output:
    path "${task.ext.outdir}/*", emit: ips_charts

    script:
    def outdir = task.ext.outdir ?: task.process.toLowerCase()
    def args = task.ext.args ?: ''

    """
    mkdir -p ${outdir}
    omicsbox statistics-interpro \\
        --i-project=\$PWD/${ips_project} \\
        --chart-format=${params.chart_format} \\
        --local-folder=\$PWD/${outdir} \\
        ${args}
    """
}
