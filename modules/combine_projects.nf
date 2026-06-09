// --- FILE: modules/combine_projects.nf ---
nextflow.enable.dsl=2

process COMBINE_PROJECTS {

    input:
    // IPS project (.box) from INTERPROSCAN and annotated project (.box) from GO_ANNOTATION.
    path ips_project
    path annotated_project

    output:
    path "${task.ext.outdir}/*", emit: combined_project

    script:
    def outdir = task.ext.outdir ?: task.process.toLowerCase()
    def args = task.ext.args ?: ''

    """
    mkdir -p ${outdir}
    omicsbox combine-projects \\
        --i-project1=\$PWD/${ips_project.name} \\
        --i-project2=\$PWD/${annotated_project.name} \\
        --local-folder=\$PWD/${outdir} \\
        $args
    """
}
