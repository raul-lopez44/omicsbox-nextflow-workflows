// --- FILE: modules/genetic_variation/beagle.nf ---
// Wraps: omicsbox beagle  |  backend: LEGACY_SYNC
// Genotype Phasing and Imputation with Beagle.

process BEAGLE {

    input:
    path vcf   // VCF to be phased and imputed (required)

    output:
    // The phased/imputed VCF is the key downstream product (not a formal JSON output key) -> inferred, tolerant glob.
    path "${task.ext.outdir}/*.vcf{,.gz}", emit: phased_vcf   // Phased/imputed VCF (consumed downstream by GWAS)
    path "${task.ext.outdir}/*[Rr]eport*.box", emit: report   // Beagle_Report

    script:
    def outdir = task.ext.outdir ?: task.process.toLowerCase()
    def args = task.ext.args ?: ''

    """
    mkdir -p ${outdir}
    omicsbox beagle \\
        --i-gt=\$PWD/${vcf} \\
        --local-folder=\$PWD/${outdir} \\
        ${args}
    """
}
