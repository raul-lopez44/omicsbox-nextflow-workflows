// --- FILE: main.nf ---
nextflow.enable.dsl=2

include { TRIMMOMATIC } from '../modules/trimmomatic.nf'
include { FASTQC } from '../modules/fastqc.nf'

workflow {

    main:
    // 1. Safety Checks (Keep exclusivity to avoid core engine crash)
    if (!params.input_paired_end && !params.input_single_end) {
        exit 1, """ERROR: You must provide at least one input 
                (--input_paired_end or --input_single_end)."""
    }
    if (params.input_paired_end && params.input_single_end) {
        exit 1, """ERROR: You cannot process Single-End and 
                Paired-End reads in the same run."""            
    }

    if (params.trimmomatic.folder_output_reads == params.trimmomatic.folder_unpaired_reads) {
        exit 1, """ERROR: The parameters 'folder_output_reads' and 'folder_unpaired_reads' 
                cannot have the exact same name. Please assign different 
                names to these folders in your nextflow.config."""
    }

    // 2. Data Channels (Simplified to fromPath for both PE and SE)
    def ch_reads = params.input_single_end
        ? channel.fromPath(params.input_single_end, checkIfExists: true).collect()
        : channel.fromPath(params.input_paired_end, checkIfExists: true).collect()

    // 3. Optional File Channels
    // If null, we pass an empty list [] so the process doesn't wait indefinitely
    def ch_adapters = params.trimmomatic.adapters 
        ? channel.fromPath(params.trimmomatic.adapters, checkIfExists: true)
        : channel.value([])

    def ch_fastqc_adapters = params.fastqc.adapters
        ? channel.fromPath(params.fastqc.adapters, checkIfExists: true)
        : channel.value([])

    def ch_fastqc_contaminants = params.fastqc.contaminants
        ? channel.fromPath(params.fastqc.contaminants, checkIfExists: true)
        : channel.value([])

    // 4. Execution
    TRIMMOMATIC(ch_reads, ch_adapters)
    FASTQC(TRIMMOMATIC.out.output_reads, ch_fastqc_adapters, ch_fastqc_contaminants)
}

