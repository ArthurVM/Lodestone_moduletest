// enable dsl2
nextflow.enable.dsl = 2

// import modules
include {mykrobe} from '../../tb-pipeline/modules/preprocessingModules.nf' params(params)
include {afanc} from '../../tb-pipeline/modules/preprocessingModules.nf' params(params)

/* TM05 test module
*/
workflow tm03 {

    take:
      input_files
      krakenDB
      bowtie_dir
      afanc_myco_db

    main:
      formatinput(input_files)
      // TM03 START
      mykrobe(formatinput.out.inputfqs)
      afanc(formatinput.out.inputfqs, afanc_myco_db)
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
