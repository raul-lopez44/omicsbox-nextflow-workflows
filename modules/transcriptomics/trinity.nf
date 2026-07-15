// --- FILE: modules/trinity.nf ---
// Wraps: omicsbox trinity
// De-novo RNA-Seq assembly. 

process TRINITY {

    input:
    path reads

    output:
    path "${task.ext.outdir}/transcripts.fasta", emit: assembly                                   // Assembled transcripts FASTA (consumed downstream)
    path "${task.ext.outdir}/save-map-file.txt", emit: gene_trans_map                             // Gene-to-transcript map (consumed downstream)
    path "${task.ext.outdir}/*report*.box", emit: report                                          // Trinity report
    path "${task.ext.outdir}/supertranscripts.fasta", emit: supertranscripts, optional: true      // SuperTranscripts FASTA
    path "${task.ext.outdir}/read_content.box", emit: read_content, optional: true                // Read-content object

    script:
    def outdir        = task.ext.outdir ?: task.process.toLowerCase()
    def args          = task.ext.args   ?: ''
    def is_single_end = params.input_single_end ? true : false

    def reads_list = reads instanceof List 
        ? reads.collect { file -> "\$PWD/${file}" }.join(',') 
        : "\$PWD/${reads}"
        
    def input_flag = is_single_end ? "--sequencing=Single" : "--sequencing=Paired"

    def pattern_flags = ""

    // Check if the input is Paired-End 
    if (!is_single_end) {
        def up_pat = params.keySet().contains('upstream_pattern') ? params.upstream_pattern : '_1'
        def down_pat = params.keySet().contains('downstream_pattern') ? params.downstream_pattern : '_2'
        pattern_flags = "--upstream-pattern-assembly=${up_pat} --downstream-pattern-assembly=${down_pat}"
    }


    """
    mkdir -p ${outdir}
    omicsbox trinity \\
        --i-fastq-files-assembly=${reads_list} \\
        ${input_flag} \\
        ${pattern_flags} \\
        --local-folder=\$PWD/${outdir} \\
        ${args}
    """
}
