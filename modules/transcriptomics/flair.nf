// --- FILE: modules/transcriptomics/flair.nf ---
// Wraps: omicsbox flair  |  backend: LEGACY_SYNC
// Identification and Quantification with FLAIR: reconstructs and quantifies isoforms from long reads.

process FLAIR {

    input:
    path reads          // Raw long reads FASTA/Q (one or more files, required) -> --i-input-files
    path ref_genome     // Reference genome FASTA (required) -> --i-ref-genome
    path annotation     // Optional: reference transcriptome annotation GTF (channel.value([]) when unused). The module sets --use-annotation-file coherently with its presence (see script). Not always mandatory.
    path aligned_reads  // Optional: aligned reads BAM from Minimap2 -> --i-aligned-reads (channel.value([]) when unused). If absent, FLAIR aligns internally. Module sets --aligned-reads-check coherently.
    path junction_bed   // Optional: short-read splice junctions (BAM w/ XS tag, or STAR SJ.out.tab) -> --i-junction-bed (channel.value([]) when unused; needs --junction-bed-check=true)

    output:
    // Output filenames CONFIRMED on a real run. The reconstructed transcriptome GTF is the key downstream product (-> SQANTI3).
    path "${task.ext.outdir}/*transcriptome*.gtf", emit: isoforms                 // output-transcriptome.gtf (reconstructed isoforms; consumed by SQANTI3)
    path "${task.ext.outdir}/*[Cc]ount*.box", emit: count_table                  // count_table_transcript.box (OmicsBox count-table object)
    // Full-length counts from the quantification step (output-counts.tsv). Fed to SQANTI3 --i-fl-file downstream.
    path "${task.ext.outdir}/*counts*.tsv", emit: counts                         // output-counts.tsv (FL counts for SQANTI3)
    path "${task.ext.outdir}/*[Rr]eport*.box", emit: report                      // flair_report.box
    path "${task.ext.outdir}/*[Ll]ength*.${params.chart_format}", emit: chart    // isoforms-length.box (isoform_length_chart; ext follows chart_format)
    path "${task.ext.outdir}/*fasta*", emit: fasta, optional: true               // output-fasta (isoform sequences FASTA; auxiliary, not consumed downstream)

    script:
    def outdir = task.ext.outdir ?: task.process.toLowerCase()
    def args = task.ext.args ?: ''

    // Multiple raw-read files -> one comma-separated --i-input-files. Absolute paths enforced.
    def reads_list = reads instanceof List
        ? reads.collect { file -> "\$PWD/${file}" }.join(',')
        : "\$PWD/${reads}"

    // Optional aligned reads (Minimap2 BAM). Same coherent-injection pattern as the annotation flag: keep
    // --aligned-reads-check in sync with the file presence so they never conflict:
    //   provided -> --aligned-reads-check=true  --i-aligned-reads=<bam(s)>  (use the external alignment, skip FLAIR's own)
    //   not given -> --aligned-reads-check=false                            (FLAIR aligns internally with minimap2)
    def aligned_flag
    if (!(aligned_reads instanceof List) || !aligned_reads.isEmpty()) {
        def aligned_list = aligned_reads instanceof List
            ? aligned_reads.collect { file -> "\$PWD/${file}" }.join(',')
            : "\$PWD/${aligned_reads}"
        aligned_flag = "--aligned-reads-check=true --i-aligned-reads=${aligned_list}"
    } else {
        aligned_flag = "--aligned-reads-check=false"
    }

    // Optional annotation GTF. Keep --use-annotation-file COHERENT with the file presence so the two never conflict
    // (the tool disables --i-annotation-file when --use-annotation-file=false):
    //   provided  -> --use-annotation-file=true  --i-annotation-file=<gtf>
    //   not given -> --use-annotation-file=false  (no --i-annotation-file)
    // This is driven ONLY by the presence of the annotation file (no user toggle): if a GTF arrives, it is used.
    // Per the tool, the annotation is NOT always mandatory: for reconstruction it can be replaced by short-read
    // junctions; it is only strictly required to quantify WITHOUT reconstruction.
    def annotation_flag = (!(annotation instanceof List) || !annotation.isEmpty())
        ? "--use-annotation-file=true --i-annotation-file=\$PWD/${annotation}"
        : "--use-annotation-file=false"

    // Optional short-read junction file(s): inject ONLY when provided. Coupling (see config): needs --junction-bed-check=true.
    def junc_bed_flag = (!(junction_bed instanceof List) || !junction_bed.isEmpty())
        ? "--i-junction-bed=${junction_bed instanceof List ? junction_bed.collect { file -> "\$PWD/${file}" }.join(',') : "\$PWD/${junction_bed}"}"
        : ""

    """
    mkdir -p ${outdir}
    omicsbox flair \\
        --i-input-files=${reads_list} \\
        --i-ref-genome=\$PWD/${ref_genome} \\
        ${annotation_flag} \\
        ${aligned_flag} \\
        ${junc_bed_flag} \\
        --chart-format=${params.chart_format} \\
        --local-folder=\$PWD/${outdir} \\
        ${args}
    """
}
