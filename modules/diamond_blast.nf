// --- FILE: modules/diamond_blast.nf ---
nextflow.enable.dsl=2

process DIAMOND_BLAST {

    input:
    // OmicsBox Sequence Project (.box) emitted by the upstream LOAD_FASTA step.
    path omicsbox_project
    // Optional taxonomy filter file; pass channel.value([]) when not required.
    path species_file

    output:
    path "*.box", emit: blasted_project

    script:
    def args = task.ext.args ?: ''

    // Taxonomy filter flag is only injected when a real file is staged (not the [] placeholder).
    def species_flag = (species_file.name != '[]')
        ? "--species=${species_file}"
        : ""

    """
    # Execute Diamond BLAST via the OmicsBox engine
    omicsbox diamond \\
        --i-input-fasta=${omicsbox_project} \\
        $species_flag \\
        $args
    """
}
