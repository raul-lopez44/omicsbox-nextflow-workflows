// --- FILE: modules/trimmomatic.nf ---
nextflow.enable.dsl=2

process TRIMMOMATIC {

    container 'quay.io/biocontainers/trimmomatic:0.39--hdfd78af_2'

    input:
    path reads
    path adapters

    output:
    path "${params.trimmomatic.folder_output_reads}/*.fastq.gz"  , emit: output_reads
    path "${params.trimmomatic.folder_unpaired_reads}/*.fastq.gz", emit: unpaired_reads, optional: true

    script:
    def args                  = task.ext.args ?: ''
    def folder_output_reads   = params.trimmomatic.folder_output_reads   ?: 'output_reads'
    def folder_unpaired_reads = params.trimmomatic.folder_unpaired_reads ?: 'unpaired_reads'
    // Builds an ILLUMINACLIP step only when a real adapter file is staged (not the empty-list placeholder).
    def illuminaclip          = (adapters instanceof java.util.List) ? "" : "ILLUMINACLIP:${adapters}:2:30:10"

    if (params.input_single_end) {
        """
        mkdir -p ${folder_output_reads}
        for f in ${reads.join(' ')}; do
            base=\$(basename \$f .fastq.gz)
            trimmomatic SE \\
                -threads ${task.cpus} \\
                -phred33 \\
                \$f \\
                ${folder_output_reads}/\${base}.trimmed.fastq.gz \\
                ${illuminaclip} ${args}
        done
        """
    } else {
        """
        mkdir -p ${folder_output_reads} ${folder_unpaired_reads}
        reads_arr=(${reads.join(' ')})
        r1=\${reads_arr[0]}
        r2=\${reads_arr[1]}
        b1=\$(basename \$r1 .fastq.gz)
        b2=\$(basename \$r2 .fastq.gz)
        trimmomatic PE \\
            -threads ${task.cpus} \\
            -phred33 \\
            \$r1 \$r2 \\
            ${folder_output_reads}/\${b1}.paired.fastq.gz \\
            ${folder_unpaired_reads}/\${b1}.unpaired.fastq.gz \\
            ${folder_output_reads}/\${b2}.paired.fastq.gz \\
            ${folder_unpaired_reads}/\${b2}.unpaired.fastq.gz \\
            ${illuminaclip} ${args}
        """
    }
}
