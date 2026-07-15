// --- FILE: modules/load_fasta.nf ---
// Wraps: omicsbox load-sequences
// Loads FASTA sequences into an OmicsBox project for downstream annotation.

process LOAD_FASTA {

    input:
    path fasta_file     // Input FASTA file (assembled transcripts or proteins)

    output:
    path "${task.ext.outdir}/project.box", emit: fasta_project   // Loaded FASTA OmicsBox project (consumed downstream)

    script:
    def outdir = task.ext.outdir ?: task.process.toLowerCase()
    def args = task.ext.args ?: ''

    """
    mkdir -p ${outdir}
    omicsbox load-sequences \\
        --i-file=\$PWD/${fasta_file} \\
        --local-folder=\$PWD/${outdir} \\
        ${args}
    """
}
