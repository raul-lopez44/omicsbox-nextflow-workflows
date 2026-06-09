// --- FILE: modules/merge_ips_gos_to_annotation.nf ---
nextflow.enable.dsl=2

process MERGE_IPS_GOS_TO_ANNOTATION {

    input:
    // Combined OmicsBox project (.box) emitted by the upstream COMBINE_PROJECTS step.
    path combined_project

    output:
    path "merge_ips_gos_to_annotation/output-merge-interpro-annotation-results.box",                   emit: integrated_project
    path "merge_ips_gos_to_annotation/merge-interpro-annotation-results.${params.chart_format}",       emit: merge_chart

    script:
    def args = task.ext.args ?: ''

    """
    mkdir -p merge_ips_gos_to_annotation
    omicsbox interproscan-join \\
        --i-input-project=\$PWD/${combined_project.name} \\
        --chart-format=${params.chart_format} \\
        --local-folder=\$PWD/merge_ips_gos_to_annotation \\
        $args
    """
}
