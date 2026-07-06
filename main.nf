// =============================================================================
// FILE: main.nf
// Punto de entrada único del monorepo de workflows de OmicsBox.
// El pipeline a ejecutar se selecciona con --pipeline <nombre>.
// Ese mismo valor carga automáticamente:
//   - el SCRIPT del workflow (include + dispatch de abajo)
//   - su CONFIG específica (ver el includeConfig condicional en nextflow.config)
//
// Ejemplo:
//   nextflow run raul-lopez44/omicsbox-nextflow-workflows -r feature/initial-workflows \
//       --pipeline functional_annotation --input_fasta /ruta/reads.fasta -latest
// =============================================================================

include { FUNCTIONAL_ANNOTATION } from './workflows/functional_annotation/functional_annotation.nf'

// Parámetro selector de pipeline (el parser estricto v2 no admite -entry)
params.pipeline = null

workflow {

    if( !params.pipeline )
        error "Debes indicar el pipeline con --pipeline <nombre>. Disponibles: functional_annotation"

    if( params.pipeline == 'functional_annotation' )
        FUNCTIONAL_ANNOTATION()
    else
        error "Pipeline desconocido: '${params.pipeline}'. Disponibles: functional_annotation"
}
