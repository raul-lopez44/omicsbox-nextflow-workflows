// --- FILE: modules/genetic_variation/gwas.nf ---
// Wraps: omicsbox gwas  |  backend: LEGACY_SYNC
// Genome-Wide Association Study (GWAS): tests association between genotypes (VCF) and phenotypic traits.

process GWAS {

    input:
    path vcf                // Input VCF with the SNPs to study (required)
    path pheno              // Phenotype/traits table: first column = sample names matching the VCF, traits in following columns, header required (required)
    path kinship            // Optional: precomputed kinship matrix (channel.value([]) when unused; requires --use-kinship=true)
    path covariate_matrix   // Optional: covariate-matrix metadata (channel.value([]) when unused; requires --use-covariate-matrix=true)

    output:
    // Both outputs are mandatory (JSON: optional=false) and are OmicsBox objects (.box).
    // Names are INFERRED (real output names unknown) using simple, tolerant globs.
    path "${task.ext.outdir}/*results*.box", emit: gwas_results   // GWAS results object (gwas_results.box)
    path "${task.ext.outdir}/*report*.box", emit: gwas_report     // GWAS summary report (gwas_report.box)
    // Auxiliary: corrected/normalized phenotype table written under output/ (only when --normalize=true) -> optional.
    path "${task.ext.outdir}/output/*corrected_phenotype*", emit: corrected_phenotype, optional: true

    script:
    def outdir = task.ext.outdir ?: task.process.toLowerCase()
    def args = task.ext.args ?: ''

    // ---------------------------------------------------------------------
    // DYNAMIC: optional file inputs. Inject the flag ONLY when a file is
    // actually provided; an unused optional arrives as an empty list ([]).
    // Coupling (documented in the config): --i-kinship needs --use-kinship=true,
    // and --i-covariate-matrix needs --use-covariate-matrix=true.
    // ---------------------------------------------------------------------
    def kinship_flag = (!(kinship instanceof List) || !kinship.isEmpty())
        ? "--i-kinship=\$PWD/${kinship}"
        : ""
    def covariate_flag = (!(covariate_matrix instanceof List) || !covariate_matrix.isEmpty())
        ? "--i-covariate-matrix=\$PWD/${covariate_matrix}"
        : ""

    """
    mkdir -p ${outdir}
    omicsbox gwas \\
        --i-input-vcf=\$PWD/${vcf} \\
        --i-input-pheno=\$PWD/${pheno} \\
        ${kinship_flag} \\
        ${covariate_flag} \\
        --local-folder=\$PWD/${outdir} \\
        ${args}
    """
}
