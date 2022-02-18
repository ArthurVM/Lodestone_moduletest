// enable dsl2
nextflow.enable.dsl = 2

// import modules
include {alignToRef} from '../../tb-pipeline/modules/clockworkModules.nf' params(params)

// define workflow component
workflow tm09 {

    take:
      input_seqs_json

    main:
      alignToRef(input_seqs_json)
}
