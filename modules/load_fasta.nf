// --- FILE: modules/load_fasta.nf ---
nextflow.enable.dsl=2

process LOAD_FASTA {

    input:
    path fasta_file

    output:
    // Busca dentro de la subcarpeta autogenerada por OmicsBox
    path "*/*.box", emit: fasta_project

    script:
    def args = task.ext.args ?: ''
    def cloud_flag = params.cloud_folder ? "--cloud-folder=${params.cloud_folder}" : ""

    """
    # Load sequences into an OmicsBox Sequence Project (.box)
    omicsbox load-sequences \\
        --i-file=${fasta_file} \\
        --local-folder=\$PWD \\
        --cloud-folder=${params.cloud_folder} \\
        $cloud_flag \\
        $args
    """
}