

log.error "======================================================================================"
log.error " ERROR: You must specify which workflow to execute by providing a '-profile' flag."
log.error "======================================================================================"
log.error " Available profiles:"
log.error "   -profile de_novo_transcriptome   : Runs De Novo Transcriptome Characterization."
log.error "   -profile metagenomics            : Runs Metagenomics Analysis."
log.error "   -profile functional_annotation   : Runs Functional Annotation."
log.error ""
log.error " Usage example:"
log.error "   nextflow run raul-lopez44/omicsbox-nextflow-workflows -profile functional_annotation"
log.error "======================================================================================"

// Exit with code 1 (Standard for error/abort)
exit 1
