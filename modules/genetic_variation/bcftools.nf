// --- FILE: modules/genetic_variation/bcftools.nf ---
// Wraps: omicsbox variantcalling-multipackage  |  backend: LEGACY_SYNC
// Variant Calling with BCFtools: calls SNPs/indels from BAM alignments against a reference genome.

process BCFTOOLS {

    input:
    path bams               // BAM alignments from BWA (one or more samples, required)
    path ref_gen            // faidx-indexed reference genome FASTA, Ensembl recommended (required)
    path group_experiment   // Optional: tab-delimited sample->group file (channel.value([]) when unused; requires --use-groups=true)

    output:
    // The called VCF is the key downstream product; it is NOT listed as a formal JSON output key,
    // so its name is INFERRED with a tolerant glob (matches .vcf and .vcf.gz, excludes .tbi/.csi indexes).
    path "${task.ext.outdir}/*.vcf{,.gz}", emit: vcf                        // Called variants VCF (consumed downstream)
    path "${task.ext.outdir}/*[Rr]eport*.box", emit: report                // Variant_Calling_Report
    path "${task.ext.outdir}/*chart*.${params.chart_format}", emit: charts // WebCharts (proportion-quality-depth, depth, mapping-quality); extension follows chart_format

    script:
    def outdir = task.ext.outdir ?: task.process.toLowerCase()
    def args = task.ext.args ?: ''

    // Multiple BAMs -> a single comma-separated --i-input-files (OmicsBox expands it). Absolute paths enforced.
    def bams_list = bams instanceof List
        ? bams.collect { file -> "\$PWD/${file}" }.join(',')
        : "\$PWD/${bams}"

    // Optional grouping file: inject ONLY when provided. Coupling (see config): needs --use-groups=true.
    def group_flag = (!(group_experiment instanceof List) || !group_experiment.isEmpty())
        ? "--i-group-experiment=\$PWD/${group_experiment}"
        : ""

    """
    mkdir -p ${outdir}
    omicsbox variantcalling-multipackage \\
        --i-input-files=${bams_list} \\
        --i-ref-gen=\$PWD/${ref_gen} \\
        ${group_flag} \\
        --chart-format=${params.chart_format} \\
        --local-folder=\$PWD/${outdir} \\
        ${args}
    """
}
