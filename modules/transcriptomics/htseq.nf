// --- FILE: modules/htseq.nf ---
// Wraps: omicsbox htseq
// RNA-Seq read quantification at gene level from aligned BAM files and genome annotation.
// Input: BAM alignment files, GFF/GTF annotation file
// Output: gene-level read count table

process HTSEQ {

    input:
    path bam_files            // BAM alignment file
    path gff                  // Genome annotation in GFF/GTF format

    output:
    path "${task.ext.outdir}/*.txt", emit: count_table            // Gene-level count table 
    path "${task.ext.outdir}/*report*.box", emit: report          // OmicsBox report

    script:
    def outdir = task.ext.outdir ?: task.process.toLowerCase()
    def args = task.ext.args ?: ''


    """
    mkdir -p ${outdir}
    omicsbox htseq \\
        --i-alignment-files=${bam_files instanceof List ? bam_files.collect { file -> "\$PWD/${file}" }.join(',') : "\$PWD/${bam_files}"} \\
        --i-gff-file=\$PWD/${gff} \\
        --local-folder=\$PWD/${outdir} \\
        ${args}
    """
}
