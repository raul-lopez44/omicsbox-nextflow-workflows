// --- FILE: modules/busco.nf ---
// Wraps: omicsbox busco
// Assesses assembly completeness against a BUSCO lineage database.

process BUSCO {

    input:
    path sequences   

    output:
    path "${task.ext.outdir}/*.box", emit: busco_results
    path "${task.ext.outdir}/*report*.box", emit: report        // OmicsBox report
    path "${task.ext.outdir}/*chart*", emit: busco_chart        // BUSCO chart visualization    

    script:
    def outdir     = task.ext.outdir ?: task.process.toLowerCase()
    def args       = task.ext.args   ?: ''


    """
    mkdir -p ${outdir}
    omicsbox busco \\
        --i-sequences=\$PWD/${sequences} \\
        --local-folder=\$PWD/${outdir} \\
        ${args}
    """
}
