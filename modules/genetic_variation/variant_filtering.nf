// --- FILE: modules/genetic_variation/variant_filtering.nf ---
// Wraps: omicsbox variant-filtering-freebayes  |  backend: LEGACY_SYNC
// Variant Filtering: filters a VCF by quality/depth/MAF/missingness criteria.

process VARIANT_FILTERING {

    input:
    path vcf   // Variant file (VCF or VCF.gz) from BCFtools (required)

    output:
    // Filtered VCF is the key downstream product (not a formal JSON output key) -> inferred, tolerant glob.
    path "${task.ext.outdir}/*.vcf{,.gz}", emit: filtered_vcf               // Filtered variants VCF (consumed downstream)
    path "${task.ext.outdir}/*[Rr]eport*.box", emit: report                // Variant_Filtering_Report
    // WebCharts confirmed on a real run: raw-read-depth, phred-quality, proportion-quality-depth, average-mapping-quality,
    // maf-histogram. Their names carry 'depth', 'quality' or 'maf' (never 'chart'). This glob matches all five and
    // excludes the report (no such token) and the .vcf.gz. Ext follows chart_format.
    path "${task.ext.outdir}/*{depth,quality,maf}*.${params.chart_format}", emit: charts

    script:
    def outdir = task.ext.outdir ?: task.process.toLowerCase()
    def args = task.ext.args ?: ''

    """
    mkdir -p ${outdir}
    omicsbox variant-filtering-freebayes \\
        --i-input-file=\$PWD/${vcf} \\
        --chart-format=${params.chart_format} \\
        --local-folder=\$PWD/${outdir} \\
        ${args}
    """
}
