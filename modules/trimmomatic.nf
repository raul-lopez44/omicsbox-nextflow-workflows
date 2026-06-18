// --- FILE: modules/trimmomatic.nf ---
nextflow.enable.dsl=2

process TRIMMOMATIC {

    input:
    // Simple path inputs. 'adapters' will be an empty list if not provided by user.
    path reads 
    path adapters 

    output:
    path "${task.ext.outdir}/*.fastq*", emit: trimmed_reads
    path "${task.ext.outdir}/unpaired/unpaired_*.fastq*", emit: unpaired_reads, optional: true
    path "${task.ext.outdir}/*report*.box", emit: report

    script:
    def outdir = task.ext.outdir ?: task.process.toLowerCase()
    def args = task.ext.args ?: ''
    def is_single_end = params.input_single_end ? true : false

    def reads_list = reads instanceof List 
        ? reads.collect { file -> "\$PWD/${file}" }.join(',') 
        : "\$PWD/${reads}"
        
    def input_flag = is_single_end 
        ? "--i-input-sequencing-data-furi-single-end=${reads_list}" 
        : "--i-input-sequencing-data-furi-paired-end=${reads_list}"

    def pattern_flags = ""
    def up_pat = params.get('upstream_pattern') ?: '_1'
    def down_pat = params.get('downstream_pattern') ?: '_2'

    if (!is_single_end) {
        pattern_flags = "--upstream-pattern-preprocessing=${up_pat} --downstream-pattern-preprocessing=${down_pat}"
    }
    
    def adapter_flag = (adapters.name != '[]') 
        ? "--i-adapter-file=\$PWD/${adapters}" 
        : ""

    def cloud_flag = params.cloud_folder ? "--cloud-folder=${params.cloud_folder}" : ""

    """
    mkdir -p ${outdir}

    omicsbox preprocessing \\
        ${input_flag} \\
        ${pattern_flags} \\
        ${adapter_flag} \\
        ${cloud_flag} \\
        --local-folder=\$PWD/${outdir} \\
        ${args}
    

    # We physically isolate the unpaired files in a subfolder
    # The '2>/dev/null || true' prevents the pipeline from failing if there are no unpaired files (e.g., Single-End)
    mkdir -p ${outdir}/unpaired
    mv ${outdir}/unpaired_*.fastq* ${outdir}/unpaired/ 2>/dev/null || true
    """
}