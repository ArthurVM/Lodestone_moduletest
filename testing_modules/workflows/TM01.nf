// enable dsl2
nextflow.enable.dsl = 2

// import modules
include {checkFqValidity} from '../../tb-pipeline/modules/preprocessingModules.nf' params(params)
include {countReads} from '../../tb-pipeline/modules/preprocessingModules.nf' params(params)
include {fastp} from '../../tb-pipeline/modules/preprocessingModules.nf' params(params)
include {fastQC} from '../../tb-pipeline/modules/preprocessingModules.nf' params(params)
include {kraken2} from '../../tb-pipeline/modules/preprocessingModules.nf' params(params)
include {mykrobe} from '../../tb-pipeline/modules/preprocessingModules.nf' params(params)
include {bowtie2} from '../../tb-pipeline/modules/preprocessingModules.nf' params(params)
include {identifyBacterialContaminants} from '../../tb-pipeline/modules/preprocessingModules.nf' params(params)
include {downloadContamGenomes} from '../../tb-pipeline/modules/preprocessingModules.nf' params(params)
include {mapToContamFa} from '../../tb-pipeline/modules/preprocessingModules.nf' params(params)
include {reKraken} from '../../tb-pipeline/modules/preprocessingModules.nf' params(params)
include {reMykrobe} from '../../tb-pipeline/modules/preprocessingModules.nf' params(params)
include {summarise} from '../../tb-pipeline/modules/preprocessingModules.nf' params(params)
include {checkBamValidity} from '../../tb-pipeline/modules/preprocessingModules.nf' params(params)
include {bam2fastq} from '../../tb-pipeline/modules/preprocessingModules.nf' params(params)

// define workflow component
workflow tm01 {

    take:
      input_files
      krakenDB
      bowtie_dir

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
