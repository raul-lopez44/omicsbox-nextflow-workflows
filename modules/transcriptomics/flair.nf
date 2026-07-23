// --- FILE: modules/transcriptomics/flair.nf ---
// Wraps: omicsbox flair  |  backend: LEGACY_SYNC
// Identification and Quantification with FLAIR: reconstructs and quantifies isoforms from long reads.

process FLAIR {

    input:
    path reads          // Raw long reads FASTA/Q (one or more files, required) -> --i-input-files
    path ref_genome     // Reference genome FASTA (required) -> --i-ref-genome
    path annotation     // Optional: reference transcriptome annotation GTF (channel.value([]) when unused). The module sets --use-annotation-file coherently with its presence (see script). Not always mandatory.
    path aligned_reads  // Aligned reads BAM from Minimap2 -> --i-aligned-reads (needs --aligned-reads-check=true)
    path junction_bed   // Optional: short-read splice junctions (BAM w/ XS tag, or STAR SJ.out.tab) -> --i-junction-bed (channel.value([]) when unused; needs --junction-bed-check=true)

    output:
    // The isoform models (GTF) are the key downstream product; NOT a formal JSON output key -> inferred glob.
    path "${task.ext.outdir}/*isoforms*.gtf", emit: isoforms                     // Reconstructed isoform models (consumed downstream by SQANTI3)
    path "${task.ext.outdir}/*[Cc]ount*.box", emit: count_table                  // count_table_transcript (OmicsBox count-table object)
    // SQANTI3-formatted full-length counts from the quantification step (source file: quantification.counts.sqanti3.tsv).
    // Fed directly to SQANTI3 --i-fl-file downstream. NOTE: on-disk name derived from source; verify glob on first run.
    path "${task.ext.outdir}/*sqanti3*.tsv", emit: counts                        // FL counts 
    path "${task.ext.outdir}/*[Rr]eport*.box", emit: report                      // flair_report
    path "${task.ext.outdir}/*chart*.${params.chart_format}", emit: chart        // isoform_length_chart (extension follows chart_format)

    script:
    def outdir = task.ext.outdir ?: task.process.toLowerCase()
    def args = task.ext.args ?: ''

    // Multiple raw-read files -> one comma-separated --i-input-files. Absolute paths enforced.
    def reads_list = reads instanceof List
        ? reads.collect { file -> "\$PWD/${file}" }.join(',')
        : "\$PWD/${reads}"

    // Aligned reads (Minimap2 BAM) may be one or more files.
    def aligned_list = aligned_reads instanceof List
        ? aligned_reads.collect { file -> "\$PWD/${file}" }.join(',')
        : "\$PWD/${aligned_reads}"

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
        --i-aligned-reads=${aligned_list} \\
        ${junc_bed_flag} \\
        --chart-format=${params.chart_format} \\
        --local-folder=\$PWD/${outdir} \\
        ${args}
    """
}
