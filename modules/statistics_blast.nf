// --- FILE: modules/statistics_blast.nf ---
nextflow.enable.dsl=2

process STATISTICS_BLAST {

    input:
    // OmicsBox project (.box) with BLAST hits emitted by the upstream DIAMOND_BLAST step.
    path blasted_project

    output:
    path "*/*.box", emit: blast_charts

    script:
    def args = task.ext.args ?: ''
    def cloud_flag = params.cloud_folder ? "--cloud-folder=${params.cloud_folder}" : ""

    """
    # Generate BLAST statistics charts from an OmicsBox BLAST project
    omicsbox statistics-blast \\
        --i-project=\$PWD/${blasted_project.name} \\
        --local-folder=\$PWD \\
        $cloud_flag \\
        $args
    FILE_PATH=\$(ls */blast_statistics_chart)
    DIR_PATH=\$(dirname "\$FILE_PATH")
    mv "\$FILE_PATH" "\$DIR_PATH/${blasted_project.baseName}_blast_stats.box"
    """
}
