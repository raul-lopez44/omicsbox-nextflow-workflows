// --- FILE: modules/ips.nf ---
nextflow.enable.dsl=2

process INTERPROSCAN {

    input:
    // OmicsBox Sequence Project (.box) emitted by the upstream LOAD_FASTA step.
    path omicsbox_project

    output:
    path "interproscan/*.box", emit: ips_project

    script:
    def args = task.ext.args ?: ''
    def cloud_flag = params.cloud_folder ? "--cloud-folder=${params.cloud_folder}" : ""

    """
    mkdir -p interproscan
    omicsbox ips \\
        --i-project=\$PWD/${omicsbox_project.name} \\
        --local-folder=\$PWD/interproscan \\
        $cloud_flag \\
        $args
    """
}
