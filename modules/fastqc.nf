// --- FILE: modules/fastqc.nf ---
nextflow.enable.dsl=2

process FASTQC {

    container 'quay.io/biocontainers/fastqc:0.12.1--hdfd78af_0'

    input:
    // Inputs kept identical to main.nf call signature; adapters/contaminants unused in basic PoC run.
    path reads
    path adapters
    path contaminants

    output:
    path "*.html", emit: fastqc_output
    path "*.zip" , emit: fastqc_zip

    script:
    def args = task.ext.args ?: ''
    """
    fastqc ${reads} -o . ${args}
    """
}
