// --- FILE: modules/transdecoder.nf ---
// Wraps: omicsbox transdecoder
// Predicts protein-coding regions (ORFs) from assembled transcripts.

process TRANSDECODER {

    input:
    path input_fasta        // Transcript FASTA (from TRINITY or CDHIT)
    path gene_trans_map     // Gene-to-transcript mapping file

    output:
    path "${task.ext.outdir}/protein-output.fasta", emit: predicted_proteins  // Predicted proteins FASTA (consumed downstream)
    path "${task.ext.outdir}/cds-output.fasta", emit: predicted_cds           // Predicted CDS FASTA
    path "${task.ext.outdir}/output-gff.gff", emit: gff                       // Predicted ORFs in GFF
    path "${task.ext.outdir}/*report*.box", emit: report                      // TransDecoder report
    path "${task.ext.outdir}/*chart*.${params.chart_format}", emit: chart     // TransDecoder chart

    script:
    def outdir     = task.ext.outdir ?: task.process.toLowerCase()
    def args       = task.ext.args   ?: ''


    """
    mkdir -p ${outdir}
    omicsbox transdecoder \\
        --i-input=\$PWD/${input_fasta} \\
        --i-gene-trans-map=\$PWD/${gene_trans_map} \\
        --provide-gene-trans-map=true \\
        --local-folder=\$PWD/${outdir} \\
        ${args}
    """
}
