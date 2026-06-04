// --- FILE: modules/load_fasta.nf ---
nextflow.enable.dsl=2

process LOAD_FASTA {

    input:
    path fasta_file

    output:
    path "load_fasta/*.box", emit: fasta_project

    script:
    def args = task.ext.args ?: ''

    """
    mkdir -p load_fasta
    omicsbox load-sequences \\
        --i-file=\$PWD/${fasta_file.name} \\
        --local-folder=\$PWD/load_fasta \\
        $args
    """
}
