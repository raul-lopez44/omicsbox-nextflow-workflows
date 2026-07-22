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
    // WebCharts: proportion-quality-depth / quality / depth / mapping-quality (names carry 'depth' or 'quality', never 'chart').
    // Same glob rationale as BCFtools: matches the charts, excludes the report and the .vcf.gz. Ext follows chart_format.
    // NOTE: chart FILENAMES not yet confirmed on a real run; derived from the tool's declared output keys.
    path "${task.ext.outdir}/*{depth,quality}*.${params.chart_format}", emit: charts

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
