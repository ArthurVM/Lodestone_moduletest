// enable dsl2
nextflow.enable.dsl = 2

// import modules
include {checkFqValidity} from '../../tb-pipeline/modules/preprocessingModules.nf' params(params)
include {countReads} from '../../tb-pipeline/modules/preprocessingModules.nf' params(params)
include {fastp} from '../../tb-pipeline/modules/preprocessingModules.nf' params(params)
include {fastQC} from '../../tb-pipeline/modules/preprocessingModules.nf' params(params)

// define workflow component
workflow tm01 {

    take:
      input_files
      krakenDB
      bowtie_dir
      afanc_myco_db

    main:

      if ( params.filetype == "bam" ) {

          checkBamValidity(input_files)

          bam2fastq(checkBamValidity.out.checkValidity_bam)

          countReads(bam2fastq.out.bam2fastq_fqs)
      }

      if ( params.filetype == "fastq" ) {

          checkFqValidity(input_files)

          countReads(checkFqValidity.out.checkValidity_fqs)
      }

      fastp(countReads.out.countReads_fqs)

      fastQC(fastp.out.fastp_fqs)

}
