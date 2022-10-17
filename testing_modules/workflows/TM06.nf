// enable dsl2
nextflow.enable.dsl = 2

// import modules
include {reKraken} from '../../tb-pipeline/modules/preprocessingModules.nf' params(params)

/* TM05 test module
*/
workflow tm06 {

    take:
      input_files
      krakenDB
      bowtie_dir

    main:
      // TM06 START
      reKraken(input_files, krakenDB.toList())
}

process formatinput {

    input:
    tuple val(sample_name), path(fq1), path(fq2), path(software_json)

    output:
    tuple val(sample_name), path(fq1), path(fq2), stdout, path(software_json), emit: inputfqs

    script:
    """
    echo /${sample_name}/
    """
}
