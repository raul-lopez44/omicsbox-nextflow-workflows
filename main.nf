// 1. Importas tus workflows desde sus carpetas
include { DE_NOVO_TRANSCRIPTOME } from './workflows/de_novo_transcriptome_characterization/de_novo_transcriptome_characterization.nf'
include { METAGENOMICS }          from './workflows/metagenomics_analysis/metagenomics_analysis.nf'
include { FUNCTIONAL_ANNOTATION } from './workflows/functional_annotation/functional_annotation.nf'

// 2. Defines los puntos de entrada (workflows nombrados)

workflow de_novo_transcriptome {
    DE_NOVO_TRANSCRIPTOME()
}

workflow metagenomics {
    METAGENOMICS()
}

workflow functional_annotation {
    FUNCTIONAL_ANNOTATION()
}