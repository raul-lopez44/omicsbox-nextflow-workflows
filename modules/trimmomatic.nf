// --- FILE: modules/trimmomatic.nf ---
nextflow.enable.dsl=2

process TRIMMOMATIC {

    input:
    // Simple path inputs. 'adapters' will be an empty list if not provided by user.
    path reads 
    path adapters 
    val out_reads_dir
    val unpaired_dir 

    output:
    // Capturing files dynamically based on user config
    path "${out_reads_dir}/*.fastq.gz"   , emit: output_reads
    path "${unpaired_dir}/*.fastq.gz", emit: unpaired_reads, optional: true
    path "*.box"                                                 , emit: project_report

    script:
    def args = task.ext.args ?: ''
    def is_single_end = params.input_single_end ? true : false

    // 1. Core Data Flags
    def input_flag = is_single_end 
        ? "--i-input-sequencing-data-furi-single-end=${reads.join(',')}" 
        : "--i-input-sequencing-data-furi-paired-end=${reads.join(',')}"
    
    // 2. Optional File Flag (Adapters)
    // Checks if the 'adapters' input is a real file or the empty placeholder []
    def adapter_flag = (adapters.name != '[]') 
        ? "--i-adapter-file=${adapters}" 
        : ""

    // 3. Output Folder Flags
    def folder_output_reads = out_reads_dir ?: 'output_reads'
    def folder_unpaired_reads = unpaired_dir ?: 'unpaired_reads'
    
    def output_routing = is_single_end
        ? "--o-choose-folder-preprocessing=\$PWD/${folder_output_reads}"
        : "--o-choose-folder-preprocessing=\$PWD/${folder_output_reads} --o-choose-folder-preprocessing3=\$PWD/${folder_unpaired_reads}"

    // 4. Execution Command
    """
    # Create the target directories
    mkdir -p ${folder_output_reads} ${folder_unpaired_reads}

    # Execute OmicsBox Engine
    omicsbox preprocessing \\
        $input_flag \\
        $adapter_flag \\
        $output_routing \\
        $args
    """
}