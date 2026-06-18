// --- FILE: functional_annotation.nf ---
nextflow.enable.dsl=2

include { LOAD_FASTA        } from '../../modules/load_fasta.nf'
include { DIAMOND_BLAST     } from '../../modules/diamond_blast.nf'
include { BLAST_CHARTS      } from '../../modules/blast_charts.nf'
include { GO_MAPPING        } from '../../modules/go_mapping.nf'
include { GO_MAPPING_CHARTS } from '../../modules/go_mapping_charts.nf'
include { GO_ANNOTATION     } from '../../modules/go_annotation.nf'
include { GO_ANNOTATION_CHARTS as BLAST2GO_ANNOTATION_CHARTS } from '../../modules/go_annotation_charts.nf'
include { GO_ANNOTATION_CHARTS as FINAL_ANNOTATION_CHARTS    } from '../../modules/go_annotation_charts.nf'
include { EGGNOG_MAPPER     } from '../../modules/eggnog_mapper.nf'
include { INTERPROSCAN      } from '../../modules/ips.nf'
include { IPS_CHARTS        } from '../../modules/ips_charts.nf'
include { COMBINE_PROJECTS  } from '../../modules/combine_projects.nf'
include { MERGE_IPS_GOS_TO_ANNOTATION } from '../../modules/merge_ips_gos_to_annotation.nf'
include { MERGE_EGGNOG_5_GOS          } from '../../modules/merge_eggnog_5_gos.nf'
include { VALIDATE_GO_ANNOTATION      } from '../../modules/validate_go_annotation.nf'
include { EC_CODE_MAPPING             } from '../../modules/ec_code_mapping.nf'
include { PROJECT_CHARTS              } from '../../modules/project_charts.nf'
include { COMBINED_GO_GRAPH           } from '../../modules/combined_go_graph.nf'
include { EXPORT_GENE_SETS            } from '../../modules/export_genesets.nf'
include { GO_SLIM                     } from '../../modules/go_slim.nf'
include { GO_ANNOTATION_CHARTS as GOSLIM_ANNOTATION_CHARTS } from '../../modules/go_annotation_charts.nf'

workflow {

    main:
    // 1. Safety Checks
    if (!params.input_fasta) {
        exit 1, """ERROR: You must provide a path to a FASTA input file
                (--input_fasta=/path/to/sequences.fasta)."""
    }

    // 2. Data Channel
    def ch_fasta = channel.fromPath(params.input_fasta, checkIfExists: true)

    // 3. Execution

    // PHASE 1: INITIALIZATION & PROJECT SETUP
    LOAD_FASTA(ch_fasta)

    // PHASE 2: SEQUENCE HOMOLOGY & GO MAPPING
    DIAMOND_BLAST(LOAD_FASTA.out.fasta_project)
    // BLAST_CHARTS(DIAMOND_BLAST.out.blasted_project)
    // GO_MAPPING runs in parallel with BLAST_CHARTS, both consuming DIAMOND_BLAST output
    GO_MAPPING(DIAMOND_BLAST.out.blasted_project)
    //GO_MAPPING_CHARTS(GO_MAPPING.out.mapped_project)

    // PHASE 3: INITIAL TRANSCRIPTOME ANNOTATION
    // GO_ANNOTATION runs in parallel with GO_MAPPING_CHARTS, both consuming GO_MAPPING output
    GO_ANNOTATION(GO_MAPPING.out.mapped_project)
    //BLAST2GO_ANNOTATION_CHARTS(GO_ANNOTATION.out.annotated_project)

    // PHASE 4: PARALLEL DOMAIN & ORTHOLOGY PREDICTION
    // EGGNOG_MAPPER runs in parallel with LOAD_FASTA, consuming the raw FASTA directly
    EGGNOG_MAPPER(ch_fasta)
    // INTERPROSCAN runs in parallel with DIAMOND_BLAST, both consuming LOAD_FASTA output
    INTERPROSCAN(LOAD_FASTA.out.fasta_project)
    //IPS_CHARTS(INTERPROSCAN.out.ips_project)

    // PHASE 5: MULTI-OMICS PROJECT MERGING & CONSOLIDATION
    // COMBINE_PROJECTS synchronizes the IPS and GO Annotation branches into one final project
    COMBINE_PROJECTS(GO_ANNOTATION.out.annotated_project, INTERPROSCAN.out.ips_project)
    // MERGE_IPS_GOS_TO_ANNOTATION merges IPS domain annotations into the combined project
    // MERGE_IPS_GOS_TO_ANNOTATION(COMBINE_PROJECTS.out.combined_project)
    // MERGE_EGGNOG_5_GOS integrates EggNOG functional annotations into the unified project
    // MERGE_EGGNOG_5_GOS(MERGE_IPS_GOS_TO_ANNOTATION.out.integrated_project, EGGNOG_MAPPER.out.eggnog_project)

    // PHASE 6: FINAL CURATION, EC MAPPING & REPORTING
    // VALIDATE_GO_ANNOTATION removes redundant GO terms based on the True-Path-Rule
    VALIDATE_GO_ANNOTATION(COMBINE_PROJECTS.out.combined_project)
    // EC_CODE_MAPPING derives Enzyme Commission codes from the validated GO annotations
    EC_CODE_MAPPING(VALIDATE_GO_ANNOTATION.out.validated_project)
    // All downstream processes run in parallel from the EC-mapped master project
    //FINAL_ANNOTATION_CHARTS(EC_CODE_MAPPING.out.ec_mapped_project)
    //PROJECT_CHARTS(EC_CODE_MAPPING.out.ec_mapped_project)
    COMBINED_GO_GRAPH(EC_CODE_MAPPING.out.ec_mapped_project)
    EXPORT_GENE_SETS(EC_CODE_MAPPING.out.ec_mapped_project)
    // GO_SLIM(EC_CODE_MAPPING.out.ec_mapped_project)
    // GO_SLIM branch: generate annotation summary charts for the slim ontology project
    // GOSLIM_ANNOTATION_CHARTS(GO_SLIM.out.goslim_project)
}
