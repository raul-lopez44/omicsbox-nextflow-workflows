// --- FILE: modules/load_fasta.nf ---
nextflow.enable.dsl=2

process LOAD_FASTA {

    input:
    path fasta_file

    output:
    path "${task.ext.outdir}/*", emit: fasta_project

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
