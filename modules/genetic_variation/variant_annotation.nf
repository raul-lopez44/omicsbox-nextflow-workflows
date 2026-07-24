// --- FILE: modules/genetic_variation/variant_annotation.nf ---
// Wraps: omicsbox variant-annotation  |  backend: LEGACY_SYNC
// Variant Annotation: annotates VCF variants with functional effects using a genome + GTF annotation.

process VARIANT_ANNOTATION {

    input:
    path vcf          // VCF with the variants to annotate (required)
    path annotation   // Annotation GTF matching the genome species/version (required)
    path genome       // Genome FASTA -- MUST be exactly the one used in variant calling (required)

    output:
    path "${task.ext.outdir}/*[Tt]able*.box", emit: annotation_table   // Variant_Annotation_Table.box
    path "${task.ext.outdir}/*[Rr]eport*.box", emit: report            // Variant_Annotation_Report.box
    // Pie chart of variant types (types-of-variants-annotated.box). Fixed .box: this tool has no --chart-format flag.
    path "${task.ext.outdir}/*[Tt]ypes*.box", emit: types_chart        // types-of-variants-annotated.box

    script:
    def outdir = task.ext.outdir ?: task.process.toLowerCase()
    def args = task.ext.args ?: ''

    """
    mkdir -p ${outdir}
    omicsbox variant-annotation \\
        --i-vcf-file=\$PWD/${vcf} \\
        --i-annotation=\$PWD/${annotation} \\
        --i-genome=\$PWD/${genome} \\
        --local-folder=\$PWD/${outdir} \\
        ${args}
    """
}
