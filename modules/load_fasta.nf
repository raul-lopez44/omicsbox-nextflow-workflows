// --- FILE: modules/load_fasta.nf ---
nextflow.enable.dsl=2

process LOAD_FASTA {

    input:
    // Multi-FASTA input file staged into the task work directory.
    path fasta_file

    output:
    path "*.box", emit: omicsbox_project

    script:
    def args = task.ext.args ?: ''

    """
    # Load sequences into an OmicsBox Sequence Project (.box)
    omicsbox load-sequences \\
        --i-file=${fasta_file} \\
        --o-project=${fasta_file.baseName}.box \\
        $args
    """
}
