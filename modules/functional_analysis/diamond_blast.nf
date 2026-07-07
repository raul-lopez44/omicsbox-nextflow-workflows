// --- FILE: modules/diamond_blast.nf ---
// Wraps: omicsbox diamond
// Sequence similarity search via DIAMOND BLAST.

process DIAMOND_BLAST {

    input:
    path omicsbox_project   // OmicsBox Sequence Project (.box) 

    output:
    path "${task.ext.outdir}/*", emit: blasted_project  // BLAST-annotated OmicsBox project

    script:
    def outdir = task.ext.outdir ?: task.process.toLowerCase()
    def args = task.ext.args ?: ''


    """
    mkdir -p ${outdir}
    omicsbox diamond \\
        --i-local-project=\$PWD/${omicsbox_project} \\
        --local-folder=\$PWD/${outdir} \\
        ${args}
    """
}
