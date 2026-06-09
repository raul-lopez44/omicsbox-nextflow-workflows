// --- FILE: modules/merge_eggnog_5_gos.nf ---
nextflow.enable.dsl=2

process MERGE_EGGNOG_5_GOS {

    input:
    // Integrated project (.box) from MERGE_IPS_GOS_TO_ANNOTATION and EggNOG annotations (.box) from EGGNOG_MAPPER.
    path integrated_project
    path eggnog_project

    output:
    path "merge_eggnog_5_gos/merge-output-orthology-groups-go-annotation.box",             emit: final_project
    path "merge_eggnog_5_gos/merge-orthology-groups-go-annotation.${params.chart_format}", emit: merge_eggnog_chart

    script:
    def args = task.ext.args ?: ''

    """
    mkdir -p merge_eggnog_5_gos
    omicsbox emapper-mergeemapper5annotationswfaction \\
        --i-project=\$PWD/${integrated_project.name} \\
        --i-egg-nog-annotations=\$PWD/${eggnog_project.name} \\
        --chart-format=${params.chart_format} \\
        --local-folder=\$PWD/merge_eggnog_5_gos \\
        $args
    """
}
