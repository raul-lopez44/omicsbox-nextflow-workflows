// --- FILE: modules/metagenomics/cont_rem.nf ---
// Wraps: omicsbox remove-contamination
// Removes contaminant reads (e.g. host/human DNA) from metagenomic libraries.

process CONT_REM {

    input:
    path reads          // Input reads (single-end or paired-end, List of FASTQ files)
    path target_genome  // Optional: custom target genome FASTA (channel.value([]) when unused)

    output:
    path "${task.ext.outdir}/un_*.fq.gz", emit: clean_reads                                  // Contaminant-free (unaligned) reads (consumed downstream)
    path "${task.ext.outdir}/al_*.fq.gz", emit: contaminant_reads, optional: true            // Contaminant (aligned) reads — only if result-mode includes aligned
    path "${task.ext.outdir}/*report*.box", emit: report                                     // Decontamination report
    path "${task.ext.outdir}/*chart_abs*.${params.chart_format}", emit: chart_abs            // Absolute-value chart
    path "${task.ext.outdir}/*chart_rel*.${params.chart_format}", emit: chart_rel            // Relative-value chart

    script:
    def outdir = task.ext.outdir ?: task.process.toLowerCase()
    def args = task.ext.args ?: ''
    def is_single_end = params.input_single_end ? true : false

    // ---------------------------------------------------------------------
    // DYNAMIC: Single-end vs paired-end read input. Absolute paths enforced.
    // NOTE: the se/pe selector flag (--sequencing) is injected via ext.args.
    // ---------------------------------------------------------------------
    def reads_list = reads instanceof List
        ? reads.collect { file -> "\$PWD/${file}" }.join(',')
        : "\$PWD/${reads}"

    def input_flag = is_single_end
        ? "--sequencing=fastq_se --i-read-files-single-end=${reads_list}"
        : "--sequencing=fastq_pe --i-read-files-paired-end=${reads_list}"

    def pattern_flags = ""

    if (!is_single_end) {
        def up_pat = params.keySet().contains('upstream_pattern') ? params.upstream_pattern : '_1'
        def down_pat = params.keySet().contains('downstream_pattern') ? params.downstream_pattern : '_2'
        pattern_flags = "--upstream-pattern-preprocessing=${up_pat} --downstream-pattern-preprocessing=${down_pat}"
    }

    // ---------------------------------------------------------------------
    // DYNAMIC: Optional custom target genome. When provided it overrides the
    // built-in --target-index defined in ext.args.
    // ---------------------------------------------------------------------
    def target_flag = (!(target_genome instanceof List) || !target_genome.isEmpty())
        ? "--i-target-genome=\$PWD/${target_genome}"
        : ""


    """
    mkdir -p ${outdir}
    omicsbox remove-contamination \\
        ${input_flag} \\
        ${pattern_flags} \\
        ${target_flag} \\
        --local-folder=\$PWD/${outdir} \\
        ${args}
    """
}
