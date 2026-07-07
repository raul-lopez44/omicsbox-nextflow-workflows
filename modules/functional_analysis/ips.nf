// --- FILE: modules/ips.nf ---
// Wraps: omicsbox ips
// Protein domain and functional annotation via InterProScan.

process INTERPROSCAN {

    input:
    path omicsbox_project   // OmicsBox Sequence Project (.box) from LOAD_FASTA

    output:
    path "${task.ext.outdir}/*.box", emit: ips_project                              // InterProScan-annotated OmicsBox project
    path "${task.ext.outdir}/*.{xml,json,gff3,tsv}", emit: export_files, optional: true  // Optional export formats

    script:
    def outdir = task.ext.outdir ?: task.process.toLowerCase()
    def args = task.ext.args ?: ''


    """
    mkdir -p ${outdir}
    omicsbox ips \\
        --i-local-project=\$PWD/${omicsbox_project} \\
        --local-folder=\$PWD/${outdir} \\
        ${args}
    """
}
