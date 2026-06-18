// --- FILE: modules/eggnog_mapper.nf ---
nextflow.enable.dsl=2

process EGGNOG_MAPPER {

    input:
    // Raw FASTA file provided directly via ch_fasta channel.
    path fasta_file

    output:
    path "${task.ext.outdir}/output_eggnog_*.box",        emit: eggnog_project
    path "${task.ext.outdir}/eggnog_mapper_report_*.box", emit: eggnog_report

    script:
    def outdir = task.ext.outdir ?: task.process.toLowerCase()
    def args = task.ext.args ?: ''
    def cloud_flag = params.cloud_folder ? "--cloud-folder=${params.cloud_folder}" : ""

    """
    mkdir -p ${outdir}
    omicsbox eggnog-mapper \\
        --i-sequences=${fasta_file} \\
        --local-folder=\$PWD/${outdir} \\
        ${cloud_flag} \\
        ${args}
    """
}
