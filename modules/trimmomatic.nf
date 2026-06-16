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
    path "${task.ext.outdir}/*.box", emit: trimmomatic_report

    script:
    def outdir = task.ext.outdir ?: task.process.toLowerCase()
    def args = task.ext.args ?: ''
    def is_single_end = params.input_single_end ? true : false

    // 1. Core Data Flags
    def reads_list = reads instanceof List 
        ? reads.collect { file -> "\$PWD/${file}" }.join(',') 
        : "\$PWD/${reads}"
        
    def input_flag = is_single_end 
        ? "--i-input-sequencing-data-furi-single-end=${reads_list}" 
        : "--i-input-sequencing-data-furi-paired-end=${reads_list}"

    // 2. Optional Pattern Flags (PAIRED-END ONLY)
    def pattern_flags = ""
    
    // Extract variables safely. 
    def up_pat = params.get('upstream_pattern') ?: '_1'
    def down_pat = params.get('downstream_pattern') ?: '_2'

    // Check if the input is Paired-End 
    if (!is_single_end) {
        pattern_flags = "--upstream-pattern-preprocessing=${up_pat} --downstream-pattern-preprocessing=${down_pat}"
    }
    
    // 3. Optional File Flag (Adapters)
    // Checks if the 'adapters' input is a real file or the empty placeholder []
    def adapter_flag = (adapters.name != '[]') 
        ? "--i-adapter-file=\$PWD/${adapters}" 
        : ""

    // 4. Optional Cloud Flag
    def cloud_flag = params.cloud_folder ? "--cloud-folder=${params.cloud_folder}" : ""

    // 5. Execution Command
    """
    # Create the target directories
    mkdir -p ${outdir}

    # Execute OmicsBox Engine
    omicsbox preprocessing \\
        $input_flag \\
        $pattern_flags \\
        $adapter_flag \\
        $cloud_flag \\
        --local-folder=\$PWD/${outdir} \\
        $args
    """
}