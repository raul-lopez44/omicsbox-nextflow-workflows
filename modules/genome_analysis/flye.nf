// --- FILE: modules/flye.nf ---
// Wraps: omicsbox flye
// Long-read de novo genome assembly using Flye.

process FLYE {

    input:
    path reads                      // Trimmed long reads (List of FASTQ/FASTA files)

    output:
    path "${task.ext.outdir}/assembly-output-file.fasta", emit: assembly   // Assembled contigs FASTA (consumed downstream)
    path "${task.ext.outdir}/*report*.box", emit: report                   // Flye report
    path "${task.ext.outdir}/*chart*.${params.chart_format}", emit: chart  // Flye chart

    script:
    def outdir = task.ext.outdir ?: task.process.toLowerCase()
    def args = task.ext.args ?: ''

    // =====================================================================
    // DYNAMIC: Library type flag injection
    // Maps library_type parameter to OmicsBox CLI flag
    // =====================================================================
    def lib_type = params.flye.library_type ?: 'pacbio_raw'
    def lib_flag = [
        'pacbio_raw' : '--i-input-sequencing-data-pacbio-raw',
        'pacbio_corr': '--i-input-sequencing-data-pacbio-corrected',
        'pacbio_hifi': '--i-input-sequencing-data-pacbio-hifi',
        'nano_raw'   : '--i-input-sequencing-data-nanopore-raw',
        'nano_corr'  : '--i-input-sequencing-data-nanopore-corrected'
    ][lib_type]

    def reads_list = reads instanceof List
        ? reads.collect { file -> "\$PWD/${file}" }.join(',')
        : "\$PWD/${reads}"


    """
    mkdir -p ${outdir}
    omicsbox flye \\
        ${lib_flag}=${reads_list} \\
        --local-folder=\$PWD/${outdir} \\
        ${args}
    """
}
