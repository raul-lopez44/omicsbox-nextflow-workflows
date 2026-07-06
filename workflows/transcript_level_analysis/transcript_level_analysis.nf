// =============================================================================
// FILE: transcript_level_analysis.nf

include { FASTQC as FASTQC_RAW   } from '../../modules/general_tools/fastqc.nf'
include { TRIMMOMATIC            } from '../../modules/general_tools/trimmomatic.nf'
include { FASTQC as FASTQC_POST  } from '../../modules/general_tools/fastqc.nf'
include { RSEM                   } from '../../modules/transcriptomics/rsem.nf'
include { COUNTS_PCA             } from '../../modules/transcriptomics/counts_pca.nf'
include { EDGER                  } from '../../modules/transcriptomics/edger.nf'

// =============================================================================
workflow {

    main:

    // -------------------------------------------------------------------------
    // Safety checks
    // -------------------------------------------------------------------------
    if (!params.input_paired_end && !params.input_single_end) {
        exit 1, "ERROR: You must provide reads via --input_paired_end or --input_single_end."
    }
    if (params.input_paired_end && params.input_single_end) {
        exit 1, "ERROR: Provide either --input_paired_end or --input_single_end, not both."
    }
    if (!params.input_fasta) {
        exit 1, "ERROR: You must provide a reference transcriptome FASTA via --input_fasta."
    }
    if (!params.experimental_design) {
        exit 1, "ERROR: You must provide an experimental design file via --experimental_design."
    }

    // -------------------------------------------------------------------------
    // Channel creation
    // ARCHITECTURAL NOTE: .collect() gathers all reads into a single List so that
    // only ONE OmicsBox task is spawned. OmicsBox parallelises internally over samples.
    // -------------------------------------------------------------------------
    def ch_reads = params.input_single_end
        ? channel.fromPath(params.input_single_end, checkIfExists: true).collect()
        : channel.fromPath(params.input_paired_end, checkIfExists: true).collect()

    def ch_fasta = channel.fromPath(params.input_fasta, checkIfExists: true)
    def ch_design = channel.fromPath(params.experimental_design, checkIfExists: true)

    // Optional file inputs — channel.value([]) acts as a safe empty placeholder
    def ch_trimmomatic_adapters = params.trimmomatic.adapters
        ? channel.fromPath(params.trimmomatic.adapters, checkIfExists: true)
        : channel.value([])

    def ch_fastqc_adapters = params.fastqc.adapters
        ? channel.fromPath(params.fastqc.adapters, checkIfExists: true)
        : channel.value([])

    def ch_fastqc_contaminants = params.fastqc.contaminants
        ? channel.fromPath(params.fastqc.contaminants, checkIfExists: true)
        : channel.value([])
    
     def ch_genes_trans_map = params.rsem.gene_trans_map
        ? channel.fromPath(params.rsem.gene_trans_map, checkIfExists: true)
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
    // 04 — Transcript quantification
    // CRITICAL: RSEM requires TWO inputs:
    //   - Input 1: Trimmed FASTQ reads from TRIMMOMATIC
    //   - Input 2: Reference transcriptome FASTA file
    // -------------------------------------------------------------------------
    RSEM(TRIMMOMATIC.out.trimmed_reads, ch_fasta, ch_genes_trans_map)

    // -------------------------------------------------------------------------
    // 05-06 — Parallel statistical analysis
    // Both PCA and edgeR consume the count table from RSEM and the experimental design
    // -------------------------------------------------------------------------
    COUNTS_PCA(RSEM.out.count_table, ch_design)
    EDGER(RSEM.out.count_table, ch_design)

}
