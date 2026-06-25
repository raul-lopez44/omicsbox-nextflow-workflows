// --- FILE: modules/metagenomics/cont_rem.nf ---
// Wraps: omicsbox remove-contamination  |  backend: LEGACY_SYNC
// Removes contamination (e.g., human DNA) from metagenomic reads.
nextflow.enable.dsl=2

process CONT_REM {

    input:
    path reads                          // Input reads (single-end or paired-end, List of FASTQ files)
    path target_genome, optional: true  // Optional: Custom target genome FASTA for contamination removal

    output:
    path "${task.ext.outdir}/*unaligned*", emit: unaligned_reads          // Unaligned reads (contaminant-free)
    path "${task.ext.outdir}/*report*.box", emit: report                  // OmicsBox report

    script:
    def outdir = task.ext.outdir ?: task.process.toLowerCase()
    def args = task.ext.args ?: ''
    def is_single_end = params.input_single_end ? true : false

    // =====================================================================
    // DYNAMIC: Single-End vs Paired-End input flag
    // =====================================================================
    def reads_list = reads instanceof List
        ? reads.collect { file -> "\$PWD/${file}" }.join(',')
        : "\$PWD/${reads}"

    def input_flag = is_single_end
        ? "--i-input-sequencing-data-furi-single-end=${reads_list}"
        : "--i-input-sequencing-data-furi-paired-end=${reads_list}"

    // =====================================================================
    // DYNAMIC: Target genome file (optional; if provided, use custom genome instead of built-in index)
    // =====================================================================
    def target_flag = target_genome ? target_genome.toString() != '[]'
        ? "--i-target-genome=\$PWD/${target_genome}"
        : ""
        : ""

    // LEGACY_SYNC

    """
    mkdir -p ${outdir}
    xvfb-run -a omicsbox remove-contamination \\
        ${input_flag} \\
        ${target_flag} \\
        --local-folder=\$PWD/${outdir} \\
        ${args}
    """
}
