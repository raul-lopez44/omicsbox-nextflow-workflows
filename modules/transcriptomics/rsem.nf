// --- FILE: modules/rsem.nf ---
// Wraps: omicsbox rsem
// Quantifies read expression against Trinity assembly.

process RSEM {

    input:
    path reads
    path assembly           
    path gene_trans_map     

    output:
    path "${task.ext.outdir}/*isoforms*.box", emit: count_table_transcripts  // Isoform (transcript-level) quantification (consumed downstream)
    path "${task.ext.outdir}/*genes*.box", emit: count_table_genes           // Gene-level quantification
    path "${task.ext.outdir}/*report*.box", emit: report                     // RSEM report

    script:
    def outdir        = task.ext.outdir ?: task.process.toLowerCase()
    def args          = task.ext.args   ?: ''
    def is_single_end = params.input_single_end ? true : false

    // Single-End vs Paired-End input flag
    def reads_list = reads instanceof List
        ? reads.collect { file -> "\$PWD/${file}" }.join(',')
        : "\$PWD/${reads}"
    def input_flag = is_single_end
        ? "--i-fastq-files-single-end=${reads_list}"
        : "--i-fastq-files-paired-end=${reads_list}"

    def up_pat   = params.getOrDefault('upstream_pattern', '_1')
    def down_pat = params.getOrDefault('downstream_pattern', '_2')
    def pattern_flags = (!is_single_end && up_pat && down_pat)
        ? "--upstream-pattern-counts=${up_pat} --downstream-pattern-counts=${down_pat}"
        : ""

    def genes_trans_map_flag = (!(gene_trans_map instanceof List) || !gene_trans_map.isEmpty())
        ? "--i-transcript-to-gene-file=\$PWD/${gene_trans_map}"
        : ""


    """
    mkdir -p ${outdir}
    omicsbox rsem \\
        --i-fasta-file=\$PWD/${assembly} \\
        ${genes_trans_map_flag} \\
        ${input_flag} \\
        ${pattern_flags} \\
        --local-folder=\$PWD/${outdir} \\
        ${args}
    """
}
