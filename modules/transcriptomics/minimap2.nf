// --- FILE: modules/transcriptomics/minimap2.nf ---
// Wraps: omicsbox minimap2  |  backend: WJOB_ASYNC
// Long-Read Alignment with Minimap2: maps long reads (PacBio/ONT) to a reference genome.

process MINIMAP2 {

    input:
    path long_reads   // FASTA/Q long reads to map (one or more files)
    path ref_genome   // reference genome FASTA (required)
    path junc_bed     // Optional: junction BED/GTF/BAM (channel.value([]) when unused; requires --use-junc-bed=true)

    output:
    // The alignment BAM is the key downstream product; it is NOT a formal JSON output key -> inferred glob.
    path "${task.ext.outdir}/*.bam", emit: bam                      // Aligned reads BAM (consumed downstream by FLAIR)
    path "${task.ext.outdir}/*[Rr]eport*.box", emit: report        // report_minimap2
    // alignments_per_category chart: this tool has NO --chart-format flag (extension is fixed .box) and its
    // exact filename is uncertain -> optional so a name mismatch does not abort the pipeline.
    path "${task.ext.outdir}/*[Cc]hart*.box", emit: chart, optional: true  // alignments_per_category_minimap2 (inferred)

    script:
    def outdir = task.ext.outdir ?: task.process.toLowerCase()
    def args = task.ext.args ?: ''

    // Multiple long-read files -> single comma-separated --i-long-reads. Absolute paths enforced.
    def reads_list = long_reads instanceof List
        ? long_reads.collect { file -> "\$PWD/${file}" }.join(',')
        : "\$PWD/${long_reads}"

    // Optional junction BED: inject ONLY when provided. Coupling (see config): needs --use-junc-bed=true.
    def junc_flag = (!(junc_bed instanceof List) || !junc_bed.isEmpty())
        ? "--i-junc-bed=\$PWD/${junc_bed}"
        : ""

    // WJOB_ASYNC backend -> forward the cloud folder when configured.
    def cloud_flag = params.cloud_folder ? "--cloud-folder=${params.cloud_folder}" : ""

    """
    mkdir -p ${outdir}
    omicsbox minimap2 \\
        --i-long-reads=${reads_list} \\
        --i-ref-genome=\$PWD/${ref_genome} \\
        ${junc_flag} \\
        --local-folder=\$PWD/${outdir} \\
        ${cloud_flag} \\
        ${args}
    """
}
