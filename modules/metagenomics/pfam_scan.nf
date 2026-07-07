// --- FILE: modules/metagenomics/pfam_scan.nf ---
// Wraps: omicsbox pfam-scan
// Annotates predicted proteins with Pfam protein domains.

process PFAM_SCAN {

    input:
    path proteins   // Predicted protein FASTA (from Prodigal)

    output:
    path "${task.ext.outdir}/*report*.box", emit: report   // Pfam-Scan report
    path "${task.ext.outdir}/*.box", emit: pfam_output      // Pfam domain annotation project

    script:
    def outdir = task.ext.outdir ?: task.process.toLowerCase()
    def args = task.ext.args ?: ''


    """
    mkdir -p ${outdir}
    omicsbox pfam-scan \\
        --i-input-sequences=\$PWD/${proteins} \\
        --local-folder=\$PWD/${outdir} \\
        ${args}
    """
}
