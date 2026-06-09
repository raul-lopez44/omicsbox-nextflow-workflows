// --- FILE: modules/combined_go_graph.nf ---
nextflow.enable.dsl=2

process COMBINED_GO_GRAPH {

    input:
    // Validated OmicsBox project (.box) emitted by the upstream VALIDATE_GO_ANNOTATION step.
    path validated_project

    output:
    path "combined_go_graph/*.${params.chart_format}", emit: combined_graph

    script:
    def args = task.ext.args ?: ''

    """
    mkdir -p combined_go_graph
    omicsbox graph-combined-make \\
        --i-input-project=\$PWD/${validated_project.name} \\
        --chart-format=${params.chart_format} \\
        --local-folder=\$PWD/combined_go_graph \\
        $args
    """
}
