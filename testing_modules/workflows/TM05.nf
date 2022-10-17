// enable dsl2
nextflow.enable.dsl = 2

// import modules
include {kraken2} from '../../tb-pipeline/modules/preprocessingModules.nf' params(params)
include {mykrobe} from '../../tb-pipeline/modules/preprocessingModules.nf' params(params)
include {bowtie2} from '../../tb-pipeline/modules/preprocessingModules.nf' params(params)
include {identifyBacterialContaminants} from '../../tb-pipeline/modules/preprocessingModules.nf' params(params)
include {downloadContamGenomes} from '../../tb-pipeline/modules/preprocessingModules.nf' params(params)
include {mapToContamFa} from '../../tb-pipeline/modules/preprocessingModules.nf' params(params)

/* TM05 test module
*/
workflow tm05 {

    take:
      input_files
      krakenDB
      bowtie_dir
      afanc_myco_db

    main:
      formatinput(input_files)
      // kraken2 takes reads not subjected to QC
      // following block needed to create files necessary for TM04
      kraken2(formatinput.out.inputfqs, krakenDB.toList())
      mykrobe(kraken2.out.kraken2_fqs)

      speciation_report = mykrobe.out.mykrobe_report

      bowtie2(formatinput.out.inputfqs, bowtie_dir.toList())
      identifyBacterialContaminants(bowtie2.out.bowtie2_fqs.join(speciation_report, by: 0).join(kraken2.out.kraken2_json, by: 0))

      // TM05 START
      downloadContamGenomes(identifyBacterialContaminants.out.contam_list)
      mapToContamFa(bowtie2.out.bowtie2_fqs.join(downloadContamGenomes.out.contam_fa, by: 0))
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
