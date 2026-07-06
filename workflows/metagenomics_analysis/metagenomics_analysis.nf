// =============================================================================
// FILE: metagenomics_analysis.nf
// Metagenomics Analysis Pipeline: QC → Trimming → Decontamination → Assembly → Gene Prediction → Functional Annotation
// =============================================================================

include { FASTQC as FASTQC_RAW   } from '../../modules/general_tools/fastqc.nf'
include { TRIMMOMATIC            } from '../../modules/general_tools/trimmomatic.nf'
include { FASTQC as FASTQC_POST  } from '../../modules/general_tools/fastqc.nf'
include { CONT_REM               } from '../../modules/metagenomics/cont_rem.nf'
include { MEGAHIT                } from '../../modules/metagenomics/megahit.nf'
include { PRODIGAL               } from '../../modules/metagenomics/prodigal.nf'
include { PFAM_SCAN              } from '../../modules/metagenomics/pfam_scan.nf'
include { EGGNOG_MAPPER          } from '../../modules/metagenomics/eggnog_mapper.nf'

// =============================================================================
workflow {

    main:

    // -------------------------------------------------------------------------
    // Safety checks — critical inputs for the metagenomics pipeline
    // -------------------------------------------------------------------------
    if (!params.input_paired_end && !params.input_single_end) {
        exit 1, "ERROR: You must provide reads via --input_paired_end or --input_single_end."
    }
    if (params.input_paired_end && params.input_single_end) {
        exit 1, "ERROR: Provide either --input_paired_end or --input_single_end, not both."
    }

    // -------------------------------------------------------------------------
    // Channel creation
    // ARCHITECTURAL NOTE: .collect() gathers all reads into a single List so that
    // only ONE OmicsBox task is spawned. OmicsBox parallelises internally over samples.
    // -------------------------------------------------------------------------
    def ch_reads = params.input_single_end
        ? channel.fromPath(params.input_single_end, checkIfExists: true).collect()
        : channel.fromPath(params.input_paired_end, checkIfExists: true).collect()

    // Optional file inputs (safe empty channels via channel.value([]))
    def ch_trimmomatic_adapters = params.trimmomatic.adapters
        ? channel.fromPath(params.trimmomatic.adapters, checkIfExists: true)
        : channel.value([])

    def ch_fastqc_adapters = params.fastqc.adapters
        ? channel.fromPath(params.fastqc.adapters, checkIfExists: true)
        : channel.value([])

    def ch_fastqc_contaminants = params.fastqc.contaminants
        ? channel.fromPath(params.fastqc.contaminants, checkIfExists: true)
        : channel.value([])

    // Optional custom target genome for contaminant removal
    def ch_cont_rem_target = params.cont_rem.target_genome
        ? channel.fromPath(params.cont_rem.target_genome, checkIfExists: true)
        : channel.value([])

    // -------------------------------------------------------------------------
    // 01 — Raw quality assessment (isolated: outputs are NOT connected downstream)
    // -------------------------------------------------------------------------
    FASTQC_RAW(ch_reads, ch_fastqc_adapters, ch_fastqc_contaminants)

    // -------------------------------------------------------------------------
    // 02 — Preprocessing & adapter removal
    // -------------------------------------------------------------------------
    TRIMMOMATIC(ch_reads, ch_trimmomatic_adapters)

    // -------------------------------------------------------------------------
    // 03 — Quality assessment (post-trimming)
    // -------------------------------------------------------------------------
    FASTQC_POST(TRIMMOMATIC.out.trimmed_reads, ch_fastqc_adapters, ch_fastqc_contaminants)

    // -------------------------------------------------------------------------
    // 04 — Contaminant (host) removal
    // CRITICAL: Takes trimmed reads from Trimmomatic. Optional custom target
    // genome overrides the built-in --target-index defined in the config.
    // -------------------------------------------------------------------------
    CONT_REM(TRIMMOMATIC.out.trimmed_reads, ch_cont_rem_target)

    // -------------------------------------------------------------------------
    // 05 — De novo metagenome assembly using MEGAHIT
    // CRITICAL: Takes the contaminant-free reads from CONT_REM.
    // -------------------------------------------------------------------------
    MEGAHIT(CONT_REM.out.clean_reads)

    // -------------------------------------------------------------------------
    // 06 — Gene prediction with Prodigal
    // CRITICAL: Takes the assembled contigs from MEGAHIT (--procedure=meta).
    // -------------------------------------------------------------------------
    PRODIGAL(MEGAHIT.out.contigs)

    // -------------------------------------------------------------------------
    // 07a-07b — Parallel functional annotation branching
    // Both PFAM_SCAN and EGGNOG_MAPPER run on the predicted proteins from Prodigal.
    // PFAM_SCAN: Pfam protein-domain annotation
    // EGGNOG_MAPPER: EggNOG ortholog-based functional annotation
    // -------------------------------------------------------------------------
    PFAM_SCAN(PRODIGAL.out.proteins)
    EGGNOG_MAPPER(PRODIGAL.out.proteins)

}
