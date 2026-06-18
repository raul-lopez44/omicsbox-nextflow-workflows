// =============================================================================
// FILE: functional_annotation.nf
nextflow.enable.dsl=2

include { LOAD_FASTA                                        } from '../../modules/load_fasta.nf'
include { DIAMOND_BLAST                                    } from '../../modules/diamond_blast.nf'
include { BLAST_CHARTS                                     } from '../../modules/blast_charts.nf'
include { GO_MAPPING                                       } from '../../modules/go_mapping.nf'
include { GO_MAPPING_CHARTS                                } from '../../modules/go_mapping_charts.nf'
include { GO_ANNOTATION                                    } from '../../modules/go_annotation.nf'
include { GO_ANNOTATION_CHARTS as BLAST2GO_ANNOTATION_CHARTS } from '../../modules/go_annotation_charts.nf'
include { GO_ANNOTATION_CHARTS as FINAL_ANNOTATION_CHARTS  } from '../../modules/go_annotation_charts.nf'
include { EGGNOG_MAPPER                                    } from '../../modules/eggnog_mapper.nf'
include { INTERPROSCAN                                     } from '../../modules/ips.nf'
include { IPS_CHARTS                                       } from '../../modules/ips_charts.nf'
include { COMBINE_PROJECTS                                 } from '../../modules/combine_projects.nf'
include { MERGE_IPS_GOS_TO_ANNOTATION                      } from '../../modules/merge_ips_gos_to_annotation.nf'
include { MERGE_EGGNOG_5_GOS                               } from '../../modules/merge_eggnog_5_gos.nf'
include { VALIDATE_GO_ANNOTATION                           } from '../../modules/validate_go_annotation.nf'
include { EC_CODE_MAPPING                                  } from '../../modules/ec_code_mapping.nf'
include { PROJECT_CHARTS                                   } from '../../modules/project_charts.nf'
include { COMBINED_GO_GRAPH                                } from '../../modules/combined_go_graph.nf'
include { EXPORT_GENE_SETS                                 } from '../../modules/export_genesets.nf'
include { GO_SLIM                                          } from '../../modules/go_slim.nf'
include { GO_ANNOTATION_CHARTS as GOSLIM_ANNOTATION_CHARTS } from '../../modules/go_annotation_charts.nf'

// =============================================================================
workflow {

    main:

    // -------------------------------------------------------------------------
    // Safety checks
    // -------------------------------------------------------------------------
    if (!params.input_fasta) {
        exit 1, "ERROR: You must provide a FASTA input file via --input_fasta=/path/to/sequences.fasta"
    }

    // -------------------------------------------------------------------------
    // Channel creation
    // Input is consumed by LOAD_FASTA (for OmicsBox project) and EGGNOG_MAPPER (raw FASTA).
    // -------------------------------------------------------------------------
    def ch_fasta = channel.fromPath(params.input_fasta, checkIfExists: true)

    // -------------------------------------------------------------------------
    // 01 — Load sequences into OmicsBox project
    // -------------------------------------------------------------------------
    LOAD_FASTA(ch_fasta)

    // -------------------------------------------------------------------------
    // 02-03 — Sequence homology search & GO mapping
    // DIAMOND_BLAST and GO_MAPPING both consume the same LOAD_FASTA project
    // and run in parallel, branching the workflow into two annotation streams
    // -------------------------------------------------------------------------
    DIAMOND_BLAST(LOAD_FASTA.out.fasta_project)
    BLAST_CHARTS(DIAMOND_BLAST.out.blasted_project)
    GO_MAPPING(DIAMOND_BLAST.out.blasted_project)
    GO_MAPPING_CHARTS(GO_MAPPING.out.mapped_project)

    // -------------------------------------------------------------------------
    // 04 — Initial GO annotation via BLAST2GO
    // -------------------------------------------------------------------------
    GO_ANNOTATION(GO_MAPPING.out.mapped_project)
    BLAST2GO_ANNOTATION_CHARTS(GO_ANNOTATION.out.annotated_project)

    // -------------------------------------------------------------------------
    // 05-07 — Parallel domain & orthology prediction
    // Three independent annotation branches, each consuming different inputs:
    //   - EGGNOG_MAPPER: consumes raw FASTA directly
    //   - INTERPROSCAN: consumes LOAD_FASTA project (same as DIAMOND_BLAST)
    //   - GO_ANNOTATION: consumes GO_MAPPING project (already computed above)
    // -------------------------------------------------------------------------
    EGGNOG_MAPPER(ch_fasta)
    INTERPROSCAN(LOAD_FASTA.out.fasta_project)
    IPS_CHARTS(INTERPROSCAN.out.ips_project)

    // -------------------------------------------------------------------------
    // 08-10 — Multi-branch project consolidation
    // COMBINE_PROJECTS merges GO annotation + InterProScan branches
    // MERGE_IPS_GOS_TO_ANNOTATION integrates domain terms into the combined project
    // MERGE_EGGNOG_5_GOS integrates EggNOG functional data
    // -------------------------------------------------------------------------
    COMBINE_PROJECTS(GO_ANNOTATION.out.annotated_project, INTERPROSCAN.out.ips_project)
    MERGE_IPS_GOS_TO_ANNOTATION(COMBINE_PROJECTS.out.combined_project)
    MERGE_EGGNOG_5_GOS(MERGE_IPS_GOS_TO_ANNOTATION.out.integrated_project, EGGNOG_MAPPER.out.eggnog_project)

    // -------------------------------------------------------------------------
    // 11-13 — Final curation, enzyme mapping & comprehensive reporting
    // All downstream processes consume the unified, fully-annotated master project
    // -------------------------------------------------------------------------
    VALIDATE_GO_ANNOTATION(MERGE_EGGNOG_5_GOS.out.final_project)
    EC_CODE_MAPPING(VALIDATE_GO_ANNOTATION.out.validated_project)
    FINAL_ANNOTATION_CHARTS(EC_CODE_MAPPING.out.ec_mapped_project)
    COMBINED_GO_GRAPH(EC_CODE_MAPPING.out.ec_mapped_project)
    EXPORT_GENE_SETS(EC_CODE_MAPPING.out.ec_mapped_project)
    // GO_SLIM(EC_CODE_MAPPING.out.ec_mapped_project)
    // GOSLIM_ANNOTATION_CHARTS(GO_SLIM.out.goslim_project)
}
