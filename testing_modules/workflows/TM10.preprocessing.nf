// enable dsl2
nextflow.enable.dsl = 2

// import modules
include {kraken2} from '../../tb-pipeline/modules/preprocessingModules.nf' params(params)
include {mykrobe} from '../../tb-pipeline/modules/preprocessingModules.nf' params(params)
include {bowtie2} from '../../tb-pipeline/modules/preprocessingModules.nf' params(params)
include {identifyBacterialContaminants} from '../../tb-pipeline/modules/preprocessingModules.nf' params(params)
include {downloadContamGenomes} from '../../tb-pipeline/modules/preprocessingModules.nf' params(params)
include {mapToContamFa} from '../../tb-pipeline/modules/preprocessingModules.nf' params(params)
include {reKraken} from '../../tb-pipeline/modules/preprocessingModules.nf' params(params)
include {reMykrobe} from '../../tb-pipeline/modules/preprocessingModules.nf' params(params)
include {summarise} from '../../tb-pipeline/modules/preprocessingModules.nf' params(params)

/* TM05 test module
*/
workflow tm10_preprocessing {

    take:
    input_files
    krakenDB
    bowtie_dir
    afanc_myco_db

    main:
      formatinput(input_files)

      kraken2(formatinput.out.inputfqs, krakenDB.toList())

      mykrobe(kraken2.out.kraken2_fqs)
      speciation_report = mykrobe.out.mykrobe_report

      bowtie2(kraken2.out.kraken2_fqs, bowtie_dir.toList())

      identifyBacterialContaminants(bowtie2.out.bowtie2_fqs.join(speciation_report, by: 0).join(kraken2.out.kraken2_json, by: 0))

      downloadContamGenomes(identifyBacterialContaminants.out.contam_list)

      mapToContamFa(bowtie2.out.bowtie2_fqs.join(downloadContamGenomes.out.contam_fa, by: 0))

      reKraken(mapToContamFa.out.reClassification_fqs, krakenDB.toList())

      if ( params.mykrobe == 'yes' ) {
        reMykrobe(mapToContamFa.out.reClassification_fqs)
        speciation_report = reMykrobe.out.reMykrobe_report
      }
      else {
        reAfanc(mapToContamFa.out.reClassification_fqs, afanc_myco_db)
        speciation_report = reAfanc.out.reAfanc_report
      }

      summarise(speciation_report.join(reKraken.out.reKraken_report, by: 0).join(identifyBacterialContaminants.out.prev_sample_json, by: 0))

    emit:

      uncontam_seqs = bowtie2.out.bowtie2_fqs
      decontam_seqs = mapToContamFa.out.reClassification_fqs
      uncontam_json = identifyBacterialContaminants.out.sample_json
      decontam_json = summarise.out.summary_json
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
