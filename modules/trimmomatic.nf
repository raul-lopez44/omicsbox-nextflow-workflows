// --- FILE: modules/trimmomatic.nf ---
nextflow.enable.dsl=2

process TRIMMOMATIC {

    input:
    // Simple path inputs. 'adapters' will be an empty list if not provided by user.
    path reads 
    path adapters 

    output:
    // Capturing files dynamically based on user config
    path "${task.ext.outdir}/*.fastq*", emit: output_reads
    path "${task.ext.outdir}/*.box", emit: trimmomatic_report, optional: true

    script:
    def outdir = task.ext.outdir ?: task.process.toLowerCase()
    def args = task.ext.args ?: ''
    def is_single_end = params.input_single_end ? true : false

    // 1. Core Data Flags
    def input_flag = is_single_end 
        ? "--i-input-sequencing-data-furi-single-end=${reads.join(',')}" 
        : "--i-input-sequencing-data-furi-paired-end=${reads.join(',')}"

    // 2. Optional Pattern Flags (PAIRED-END ONLY)
    def pattern_flags = ""
    
    // Extract variables safely. If they are commented out in the config, they will evaluate to null.
    def up_pat = params.get('upstream_pattern')
    def down_pat = params.get('downstream_pattern')

    // Check if the input is Paired-End and both variables exist (are not null)
    if (!is_single_end && up_pat && down_pat) {
        pattern_flags = "--upstream-pattern-preprocessing=${up_pat} --downstream-pattern-preprocessing=${down_pat}"
    }
    
    // 3. Optional File Flag (Adapters)
    // Checks if the 'adapters' input is a real file or the empty placeholder []
    def adapter_flag = (adapters.name != '[]') 
        ? "--i-adapter-file=${adapters}" 
        : ""

    // 3. Execution Command
    """
    # Create the target directories
    mkdir -p ${outdir}

    # Execute OmicsBox Engine
    omicsbox preprocessing \\
        $input_flag \\
        $pattern_flags \\
        $adapter_flag \\
        --local-folder=\$PWD/${outdir} \\
        $args
    """
}