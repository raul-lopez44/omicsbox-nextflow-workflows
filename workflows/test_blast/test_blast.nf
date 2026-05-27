// --- FILE: test_blast.nf ---
nextflow.enable.dsl=2

include { LOAD_FASTA        } from '../../modules/load_fasta.nf'
include { DIAMOND_BLAST     } from '../../modules/diamond_blast.nf'
include { STATISTICS_BLAST  } from '../../modules/statistics_blast.nf'

workflow {

    main:
    // 1. Safety Checks
    if (!params.input_fasta) {
        exit 1, """ERROR: You must provide a path to a FASTA input file
                (--input_fasta=/path/to/sequences.fasta)."""
    }

    // 2. Data Channel
    def ch_fasta = channel.fromPath(params.input_fasta, checkIfExists: true)

    // 3. Optional File Channels
    // If null, we pass an empty list [] so the process doesn't wait indefinitely
    def ch_species = params.diamond_blast.species
        ? channel.fromPath(params.diamond_blast.species, checkIfExists: true)
        : channel.value([])

    // 4. Execution
    LOAD_FASTA(ch_fasta)
    DIAMOND_BLAST(LOAD_FASTA.out.omicsbox_project, ch_species)
    STATISTICS_BLAST(DIAMOND_BLAST.out.blasted_project)
}
