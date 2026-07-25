// =============================================================================
// FILE: long_reads_transcriptome_analysis.nf
// Long-Read Transcriptome Analysis Pipeline:
//   LongQC (isolated QC) | Minimap2 (alignment) -> FLAIR (isoform id/quant) -> SQANTI3 (curation)
// =============================================================================

include { LONGQC   } from '../../modules/general_tools/longqc.nf'
include { MINIMAP2 } from '../../modules/transcriptomics/minimap2.nf'
include { FLAIR    } from '../../modules/transcriptomics/flair.nf'
include { SQANTI3  } from '../../modules/transcriptomics/sqanti3.nf'

// =============================================================================
workflow {

    main:

    // -------------------------------------------------------------------------
    // Config template export: --dump_config copies this workflow's .config to
    // the launch directory and exits, so the user can edit it and pass it via -c.
    // -------------------------------------------------------------------------
    if (params.dump_config) {
        // 1. Source: this workflow's config template (sibling of the .nf; projectDir = workflow dir under -main-script)
        def sourceConfig = file("${moduleDir}/long_reads_transcriptome_analysis.config")

        // 2. Target: the current launch directory
        def targetConfig = file("./long_reads_transcriptome_analysis.config")

        if (sourceConfig.exists()) {
            // 3. Physically copy the file to the user's environment
            sourceConfig.copyTo(targetConfig)

            log.info "========================================================================="
            log.info "  [OK] Configuration template successfully exported!"
            log.info "========================================================================="
            log.info "  File generated at: ./long_reads_transcriptome_analysis.config"
            log.info ""
            log.info "  Instructions:"
            log.info "  1. Open and modify the parameters in the generated file as needed."
            log.info "  2. Run the actual pipeline pointing to your local configuration using:"
            log.info "     -c long_reads_transcriptome_analysis.config"
            log.info "========================================================================="
        } else {
            log.error "  [ERROR] Could not find the internal template at: ${sourceConfig}"
        }

        // 4. Stop Nextflow safely with exit code 0 (success)
        exit 0
    }


    // -------------------------------------------------------------------------
    // Safety checks - critical inputs
    // -------------------------------------------------------------------------
    if (!params.input_reads) {
        exit 1, "ERROR: You must provide long reads (FASTA/Q) via --input_reads."
    }
    if (!params.input_fasta) {
        exit 1, "ERROR: You must provide a reference genome FASTA via --input_fasta (used by Minimap2, FLAIR and SQANTI3)."
    }
    // input_gff is REQUIRED because SQANTI3 (--i-ref-annot) always needs it. For FLAIR the annotation is
    // only conditionally required (see the FLAIR config note), but SQANTI3 makes it mandatory pipeline-wide.
    if (!params.input_gff) {
        exit 1, "ERROR: You must provide a reference annotation GTF via --input_gff (REQUIRED by SQANTI3; also used by FLAIR)."
    }
    // SQANTI3 input mode validation. GFF consumes FLAIR's reconstructed isoforms; TRANSCRIPT/PACBIO consume their
    // own user-provided FASTA/Q file. FLAIR still runs in every mode (its GTF is just unused in the non-GFF modes).
    if (!(params.sqanti3.pb_or_gff in ['GFF', 'TRANSCRIPT', 'PACBIO'])) {
        exit 1, "ERROR: params.sqanti3.pb_or_gff must be one of GFF, TRANSCRIPT, PACBIO (got '${params.sqanti3.pb_or_gff}')."
    }
    if (params.sqanti3.pb_or_gff == 'TRANSCRIPT' && !params.sqanti3.transcriptome_file) {
        exit 1, "ERROR: SQANTI3 mode 'TRANSCRIPT' requires params.sqanti3.transcriptome_file (FASTA/Q transcript sequences)."
    }
    if (params.sqanti3.pb_or_gff == 'PACBIO' && !params.sqanti3.pacbio_file) {
        exit 1, "ERROR: SQANTI3 mode 'PACBIO' requires params.sqanti3.pacbio_file (FASTA/Q raw long reads)."
    }
    // Optional SQANTI3 short-read support: if short reads are provided, you MUST choose the layout explicitly (no default).
    if (params.sqanti3.short_reads && !(params.sqanti3.short_reads_type in ['fastq_pe', 'fastq_se'])) {
        exit 1, "ERROR: params.sqanti3.short_reads is set, so params.sqanti3.short_reads_type must be 'fastq_pe' or 'fastq_se' (got '${params.sqanti3.short_reads_type}')."
    }

    // -------------------------------------------------------------------------
    // Channel creation
    // ARCHITECTURAL NOTE: the raw long reads are one collected list reused by LongQC,
    // Minimap2 and FLAIR. The reference genome and annotation are single-file value
    // channels (.first()) reused across steps.
    // -------------------------------------------------------------------------
    def ch_reads = channel.fromPath(params.input_reads, checkIfExists: true).collect()
    def ch_reference = channel.fromPath(params.input_fasta, checkIfExists: true).first()
    def ch_annotation = channel.fromPath(params.input_gff, checkIfExists: true).first()

    // Optional: junction BED for Minimap2 (only used when --use-junc-bed=true)
    def ch_junc_bed = params.minimap2.junc_bed
        ? channel.fromPath(params.minimap2.junc_bed, checkIfExists: true).first()
        : channel.value([])

    // Optional: short-read splice junctions for FLAIR (BAM/SJ.out.tab; multiple). Only used when --junction-bed-check=true.
    def ch_flair_junction_bed = params.flair.junction_bed
        ? channel.fromPath(params.flair.junction_bed, checkIfExists: true).collect()
        : channel.value([])

    // -------------------------------------------------------------------------
    // 01 - Long-read quality assessment (isolated: outputs are NOT connected downstream)
    // -------------------------------------------------------------------------
    LONGQC(ch_reads)

    // -------------------------------------------------------------------------
    // 02 - Long-read alignment to the reference genome (Minimap2)
    // -------------------------------------------------------------------------
    MINIMAP2(ch_reads, ch_reference, ch_junc_bed)

    // -------------------------------------------------------------------------
    // 03 - Isoform identification & quantification (FLAIR)
    // This workflow wires Minimap2's BAM as FLAIR's aligned-reads input. The FLAIR module treats that input as
    // OPTIONAL (agnostic): a BAM present -> --aligned-reads-check=true (--i-aligned-reads); an empty channel ->
    // --aligned-reads-check=false (FLAIR aligns internally). Same presence-based logic as annotation / SQANTI3 fl_counts.
    // To run WITHOUT external alignment, wire channel.value([]) here instead of MINIMAP2.out.bam.
    // -------------------------------------------------------------------------
    FLAIR(ch_reads, ch_reference, ch_annotation, MINIMAP2.out.bam, ch_flair_junction_bed)

    // -------------------------------------------------------------------------
    // 04 - Curation of the transcriptome (SQANTI3)
    // The input depends on params.sqanti3.pb_or_gff (the module injects --pb-or-gff and the matching --i-*-file):
    //   GFF                 -> FLAIR's reconstructed isoform GTF (default pipeline flow)
    //   TRANSCRIPT / PACBIO -> a user-provided FASTA/Q file (SQANTI3 does its own mapping/collapse)
    // Reference genome + reference annotation are always required.
    // -------------------------------------------------------------------------
    def ch_sqanti_input
    if (params.sqanti3.pb_or_gff == 'GFF') {
        ch_sqanti_input = FLAIR.out.isoforms
    } else if (params.sqanti3.pb_or_gff == 'TRANSCRIPT') {
        ch_sqanti_input = channel.fromPath(params.sqanti3.transcriptome_file, checkIfExists: true).first()
    } else if (params.sqanti3.pb_or_gff == 'PACBIO') {
        ch_sqanti_input = channel.fromPath(params.sqanti3.pacbio_file, checkIfExists: true).first()
    }

    // Optional short-read support (multiple FASTQ). Empty value channel when unused -> module injects --use-of-sr=false.
    def ch_sqanti_short_reads = params.sqanti3.short_reads
        ? channel.fromPath(params.sqanti3.short_reads, checkIfExists: true).collect()
        : channel.value([])

    // Optional extra single-file annotation inputs. Empty value channel when unused -> module injects the *-check=false.
    def ch_sqanti_tss   = params.sqanti3.tss_file   ? channel.fromPath(params.sqanti3.tss_file,   checkIfExists: true).first() : channel.value([])
    def ch_sqanti_polya = params.sqanti3.polya_file ? channel.fromPath(params.sqanti3.polya_file, checkIfExists: true).first() : channel.value([])
    def ch_sqanti_peak  = params.sqanti3.polya_peak ? channel.fromPath(params.sqanti3.polya_peak, checkIfExists: true).first() : channel.value([])
    // FL counts are ALWAYS produced by FLAIR (quantification.counts.sqanti3.tsv) -> not a user param. Only meaningful in
    // GFF mode, where SQANTI3 curates FLAIR's own isoforms (matching IDs). In TRANSCRIPT/PACBIO SQANTI3 analyses a
    // different, user-provided input, so FLAIR's counts do NOT correspond -> no FL counts there.
    def ch_sqanti_fl    = params.sqanti3.pb_or_gff == 'GFF' ? FLAIR.out.counts : channel.value([])
    def ch_sqanti_json  = params.sqanti3.rules_json ? channel.fromPath(params.sqanti3.rules_json, checkIfExists: true).first() : channel.value([])

    SQANTI3(ch_sqanti_input, ch_reference, ch_annotation, ch_sqanti_short_reads,
            ch_sqanti_tss, ch_sqanti_polya, ch_sqanti_peak, ch_sqanti_fl, ch_sqanti_json)

}
