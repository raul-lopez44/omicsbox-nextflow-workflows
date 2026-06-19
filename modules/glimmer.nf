// --- FILE: modules/runglimmer.nf ---
// Wraps: omicsbox runglimmer  |  backend: LEGACY_SYNC
// Prokaryotic gene finding using Glimmer ICM-based ORF prediction.
nextflow.enable.dsl=2

process GLIMMER {

    input:
    path fasta                 
    path icm_model             // Interpolated Context Model (ICM) file for gene prediction

    output:
    path "${task.ext.outdir}/*.gff", emit: gff_genes             // Predicted genes in GFF format
    path "${task.ext.outdir}/*project*", emit: project, optional: true  // OmicsBox sequence project
    path "${task.ext.outdir}/*report*.box", emit: report         // OmicsBox report

    script:
    def outdir = task.ext.outdir ?: task.process.toLowerCase()
    def args = task.ext.args ?: ''

    // LEGACY_SYNC

    """
    mkdir -p ${outdir}
    omicsbox runglimmer \\
        --i-fastafile2=${fasta instanceof List ? fasta.join(',') : fasta} \\
        --i-existing-icmodel=${icm_model} \\
        --local-folder=\$PWD/${outdir} \\
        ${args}
    """
}
