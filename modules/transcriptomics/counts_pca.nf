// --- FILE: modules/pca_chart.nf ---
// Wraps: omicsbox counts-pca
// PCA/PCoA visualization of sample distances. 

process COUNTS_PCA {

    input:
    path count_table_project   // AbstractCountTable .box 
    path design_file           // Experimental design TSV; channel.value([]) if not provided

    output:
    path "${task.ext.outdir}/*.${params.chart_format}", emit: pca_chart
    
    script:
    def outdir = task.ext.outdir ?: task.process.toLowerCase()
    def args   = task.ext.args   ?: ''

    // Wire the experimental design FILE when provided. 
    def design_flag = (design_file.name != '[]')
        ? "--i-experimental-design=\$PWD/${design_file}"
        : ""

    """
    mkdir -p ${outdir}
    omicsbox counts-pca \\
        --i-count-table=\$PWD/${count_table_project} \\
        ${design_flag} \\
        --chart-format=${params.chart_format} \\
        --local-folder=\$PWD/${outdir} \\
        ${args}
    """
}
