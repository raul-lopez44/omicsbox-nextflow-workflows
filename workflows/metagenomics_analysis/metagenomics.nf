// --- FILE: metagenomics.nf ---
// Metagenomics Analysis Workflow
// 7-phase DAG: FASTQC_RAW → TRIMMOMATIC → FASTQC_POST → CONT_REM → MEGAHIT → (PRODIGAL + EGGNOG_MAPPER in parallel) → PFAM_SCAN
// =================================================================

nextflow.enable.dsl=2

// =================================================================
// INCLUDES: Import module processes
// =================================================================
include { FASTQC_RAW; FASTQC_POST } from '../../modules/general_tools/fastqc'
include { TRIMMOMATIC } from '../../modules/utilities/trimmomatic'
include { CONT_REM } from '../../modules/metagenomics/cont_rem'
include { MEGAHIT } from '../../modules/metagenomics/megahit'
include { PRODIGAL } from '../../modules/metagenomics/prodigal'
include { PFAM_SCAN } from '../../modules/metagenomics/pfam_scan'
include { EGGNOG_MAPPER } from '../../modules/functional_analysis/eggnog_mapper'

// =================================================================
// WORKFLOW DEFINITION
// =================================================================
workflow metagenomics_analysis {

    // ===================================================================
    // FAIL-FAST VALIDATION: Check all prerequisites before execution
    // ===================================================================

    // Input validation: At least one of input_single_end or input_paired_end must be set
    if (!params.input_single_end && !params.input_paired_end) {
        error """
        ========================================
        CRITICAL ERROR: No input reads specified
        ========================================
        Either --input_single_end or --input_paired_end must be provided.
        Examples:
          --input_single_end 'data/*.fastq.gz'
          --input_paired_end 'data/*_{1,2}.fastq.gz'
        """.stripIndent()
    }

    // Mutual exclusivity: Cannot use both input_single_end and input_paired_end
    if (params.input_single_end && params.input_paired_end) {
        error """
        ========================================
        CRITICAL ERROR: Conflicting input types
        ========================================
        Cannot specify both --input_single_end and --input_paired_end.
        Choose ONE:
          --input_single_end (single-end reads)
          --input_paired_end (paired-end reads)
        """.stripIndent()
    }

    // Output directory validation
    if (!params.local_folder || params.local_folder.toString().isEmpty()) {
        error """
        ========================================
        CRITICAL ERROR: No output directory
        ========================================
        --local_folder must be specified.
        Example: --local_folder './results'
        """.stripIndent()
    }

    // ===================================================================
    // CHANNEL CREATION: Load input reads into the workflow
    // ===================================================================

    // Determine input glob pattern and sequencing type
    def input_glob = params.input_single_end ?: params.input_paired_end

    // Create channel from input reads glob
    reads_ch = Channel
        .fromPath(input_glob, checkIfExists: true)
        .collect()  // Group all files into a single list

    // ===================================================================
    // PHASE 1: RAW QUALITY CONTROL (PRE-TRIMMING)
    // ===================================================================
    FASTQC_RAW(reads_ch)

    // ===================================================================
    // PHASE 2: READ PREPROCESSING & TRIMMING
    // ===================================================================
    TRIMMOMATIC(reads_ch)

    // ===================================================================
    // PHASE 3: QUALITY CONTROL (POST-TRIMMING)
    // ===================================================================
    FASTQC_POST(TRIMMOMATIC.out.reads)

    // ===================================================================
    // PHASE 4: CONTAMINANT REMOVAL
    // ===================================================================
    // CONT_REM takes:
    //   - trimmed reads from TRIMMOMATIC
    //   - optional target genome (params.cont_rem.target_genome)
    def target_genome_ch = params.cont_rem?.target_genome
        ? Channel.fromPath(params.cont_rem.target_genome)
        : Channel.value([])

    CONT_REM(
        TRIMMOMATIC.out.reads,
        target_genome_ch
    )

    // ===================================================================
    // PHASE 5: DE NOVO METAGENOME ASSEMBLY (MEGAHIT)
    // ===================================================================
    MEGAHIT(CONT_REM.out.unaligned_reads)

    // ===================================================================
    // PHASE 6: GENE PREDICTION & FUNCTIONAL ANNOTATION (PARALLEL)
    // ===================================================================
    // Branch 6a: Prokaryotic Gene Finding (PRODIGAL)
    PRODIGAL(MEGAHIT.out.contigs)

    // Branch 6b: Functional Annotation (EggNOG)
    EGGNOG_MAPPER(PRODIGAL.out.proteins)

    // ===================================================================
    // PHASE 7: DOMAIN ANNOTATION (PFAM_SCAN)
    // ===================================================================
    PFAM_SCAN(PRODIGAL.out.proteins)

    // ===================================================================
    // EMIT FINAL OUTPUTS
    // ===================================================================
    emit:
        fastqc_raw_results      = FASTQC_RAW.out.report
        trimmomatic_results     = TRIMMOMATIC.out.report
        fastqc_post_results     = FASTQC_POST.out.report
        contaminant_removal     = CONT_REM.out.report
        megahit_contigs         = MEGAHIT.out.contigs
        prodigal_genes          = PRODIGAL.out.genes
        prodigal_proteins       = PRODIGAL.out.proteins
        eggnog_annotations      = EGGNOG_MAPPER.out.annotations
        pfam_annotations        = PFAM_SCAN.out.pfam_output
}

// =================================================================
// WORKFLOW INVOCATION (if run as main script)
// =================================================================
workflow {
    metagenomics_analysis()
}
