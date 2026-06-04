// --- FILE: modules/eggnog_mapper.nf ---
nextflow.enable.dsl=2

process EGGNOG_MAPPER {

    input:
    // Raw FASTA file provided directly via ch_fasta channel.
    path fasta_file

    output:
    path "eggnog_mapper/output_eggnog_*.box",        emit: eggnog_project
    path "eggnog_mapper/eggnog_mapper_report_*.box", emit: eggnog_report

    script:
    def args = task.ext.args ?: ''
    def cloud_flag = params.cloud_folder ? "--cloud-folder=${params.cloud_folder}" : ""

    """
    mkdir -p eggnog_mapper
    omicsbox eggnog-mapper \\
        --i-sequences=\$PWD/${fasta_file.name} \\
        --local-folder=\$PWD/eggnog_mapper \\
        $cloud_flag \\
        $args
    """
}
