// --- FILE: modules/go_slim.nf ---
// Wraps: omicsbox goslim
// Generates GO Slim subset annotation

process GO_SLIM {

    input:
    // OmicsBox EC-mapped project (.box) emitted by the upstream EC_CODE_MAPPING step.
    path project_file
    // Optional: custom GO-Slim OBO file -> --i-go-slim-obo-file (channel.value([]) when unused).
    // REQUIRED when --option=custom (that value disables --go-slim-web-file and enables --i-go-slim-obo-file).
    path obo_file

    output:
    path "${task.ext.outdir}/*", emit: goslim_project

    script:
    def outdir = task.ext.outdir ?: task.process.toLowerCase()
    def args = task.ext.args ?: ''

    // Optional custom OBO file: inject --i-go-slim-obo-file ONLY when a file is provided (not an empty channel).
    // Coupling (see config): use it together with --option=custom (which disables --go-slim-web-file).
    def obo_flag = (!(obo_file instanceof List) || !obo_file.isEmpty())
        ? "--i-go-slim-obo-file=\$PWD/${obo_file}"
        : ""

    """
    mkdir -p ${outdir}
    omicsbox goslim \\
        --i-project=\$PWD/${project_file} \\
        ${obo_flag} \\
        --local-folder=\$PWD/${outdir} \\
        ${args}
    """
}
