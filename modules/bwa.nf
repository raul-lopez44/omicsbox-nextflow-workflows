// --- FILE: modules/bwa.nf ---
// Wraps: omicsbox bwa  |  backend: LEGACY_SYNC
// Aligns short reads to long-read assembly for hybrid polishing.
nextflow.enable.dsl=2

process BWA {

    input:
    path reference              // Unpolished long-read assembly (FASTA)
    path reads                  // Short reads (SE or PE, List of FASTQ files)

    output:
    path "${task.ext.outdir}/*.bam", emit: sorted_bam                 // Sorted BAM file
    path "${task.ext.outdir}/*report*.box", emit: report              // OmicsBox report

    script:
    def outdir = task.ext.outdir ?: task.process.toLowerCase()
    def args = task.ext.args ?: ''

    def reads_list = reads instanceof List
        ? reads.collect { file -> "\$PWD/${file}" }.join(',')
        : "\$PWD/${reads}"

    // LEGACY_SYNC

    """
    mkdir -p ${outdir}
    omicsbox bwa \\
        --i-reference=\$PWD/${reference} \\
        --i-reads=${reads_list} \\
        --local-folder=\$PWD/${outdir} \\
        ${args}
    """
}
