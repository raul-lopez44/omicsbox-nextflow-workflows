// --- FILE: modules/cdhit.nf ---
// Wraps: omicsbox cdhit
// Clusters Trinity transcripts at sequence-identity threshold.

process CDHIT {

    input:
    path assembly   // Trinity.fasta from TRINITY

    output:
    path "${task.ext.outdir}/output.fasta", emit: clustered_fasta
    path "${task.ext.outdir}/output-clusters.txt", emit: clusters_file
    path "${task.ext.outdir}/cdhit_report.box", emit: report
    path "${task.ext.outdir}/cdhit_chart.box", emit: chart

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
