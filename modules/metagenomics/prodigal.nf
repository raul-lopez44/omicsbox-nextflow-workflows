// --- FILE: modules/metagenomics/prodigal.nf ---
// Wraps: omicsbox prodigal  |  backend: LEGACY_SYNC
// Prokaryotic gene prediction for metagenomic contigs using Prodigal.
nextflow.enable.dsl=2

process PRODIGAL {

    input:
    path contigs                // Assembled metagenome contigs FASTA (from MEGAHIT)

    output:
    path "${task.ext.outdir}/*genes*.fasta", emit: genes              // Predicted genes FASTA file
    path "${task.ext.outdir}/*proteins*.fasta", emit: proteins         // Predicted proteins FASTA file
    path "${task.ext.outdir}/*gff", emit: gff_genes                   // GFF annotation of genes
    path "${task.ext.outdir}/*report*.box", emit: report              // OmicsBox report
    path "${task.ext.outdir}/*chart*.${params.chart_format}", emit: chart  // OmicsBox chart

    script:
    def outdir = task.ext.outdir ?: task.process.toLowerCase()
    def args = task.ext.args ?: ''

    // LEGACY_SYNC

    """
    mkdir -p ${outdir}
    xvfb-run -a omicsbox prodigal \\
        --i-input-sequences=\$PWD/${contigs} \\
        --chart-format=${params.chart_format} \\
        --local-folder=\$PWD/${outdir} \\
        ${args}
    """
}
