// --- FILE: modules/cdhit.nf ---
// Wraps: omicsbox cdhit
// Clusters Trinity transcripts at sequence-identity threshold.

process CDHIT {

    input:
    path assembly   // Trinity.fasta from TRINITY

    output:
    path "${task.ext.outdir}/output.fasta", emit: clustered_fasta          // Non-redundant representative sequences (consumed downstream)
    path "${task.ext.outdir}/output-clusters.txt", emit: clusters          // Cluster membership file
    path "${task.ext.outdir}/*report*.box", emit: report                   // CD-HIT report
    path "${task.ext.outdir}/*chart*.${params.chart_format}", emit: chart  // CD-HIT chart

    script:
    def outdir     = task.ext.outdir ?: task.process.toLowerCase()
    def args       = task.ext.args   ?: ''


    """
    mkdir -p ${outdir}
    omicsbox cdhit \\
        --i-input=\$PWD/${assembly} \\
        --local-folder=\$PWD/${outdir} \\
        ${args}
    """
}
