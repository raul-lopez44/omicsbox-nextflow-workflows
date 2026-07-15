// --- FILE: modules/quast.nf ---
// Wraps: omicsbox quast
// Quality assessment of genome assemblies using QUAST.

process QUAST {

    input:
    path assembly              
    path reference             

    output:
    path "${task.ext.outdir}/*results*.box", emit: results                 // QUAST results project
    path "${task.ext.outdir}/*report*.box", emit: report                   // QUAST report
    path "${task.ext.outdir}/*chart*.${params.chart_format}", emit: chart  // QUAST chart

    script:
    def outdir = task.ext.outdir ?: task.process.toLowerCase()
    def args = task.ext.args ?: ''


    """
    mkdir -p ${outdir}
    omicsbox quast \\
        --i-assemblies=${assembly instanceof List ? assembly.collect { file -> "\$PWD/${file}" }.join(',') : "\$PWD/${assembly}"} \\
        --i-reference=\$PWD/${reference} \\
        --local-folder=\$PWD/${outdir} \\
        ${args}
    """
}
