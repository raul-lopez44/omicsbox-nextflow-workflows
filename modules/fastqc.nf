// --- FILE: modules/fastqc.nf ---
nextflow.enable.dsl=2

process FASTQC {

    input:
    // Upstream cleaned reads (paths may be one file or a list; joined for OmicsBox).
    path reads
    path adapters
    path contaminants

    output:
    path "*.box", emit: fastqc_output

    script:
    def args = task.ext.args ?: ''

    def fastq_list = reads instanceof List ? reads.join(',') : reads.toString()
    def input_flag = "--i-fastq-files=${fastq_list}"

    def adapters_flag = (adapters.name != '[]')
        ? "--provide-adapters=true --i-adapters=${adapters}"
        : ""

    def contaminants_flag = (contaminants.name != '[]')
        ? "--provide-contaminants=true --i-contaminants=${contaminants}"
        : ""

    """
    # Execute OmicsBox Engine (default FastQC OmicsBox outputs are written to the task work directory)
    xvfb-run -a omicsbox fastqc \\
        $input_flag \\
        $adapters_flag \\
        $contaminants_flag \\
        $args
    """
}
