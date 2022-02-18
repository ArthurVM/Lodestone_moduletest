"""
Runs individual Lodestone testing modules (TM01-10) using
simulated datasets contained within the datasets directory
within the lodestone_modtest root directory.
"""

import sys, os
import subprocess
import argparse

def runtest(args, tmDir):
    """ run module test
    """
    print(f"Running {args.test_module} using data in {tmDir} ... \n")
    cwd = os.getcwd()

    os.chdir("./tb-pipeline")

    rl1 = f"NXF_VER=20.11.0-edge nextflow run ./{args.test_module}_main.nf\
     -profile singularity \
     --filetype fastq \
     --input_dir {tmDir}"

    pattern = "--pattern \"*_{1,2}.fq.gz\""

    rl2 = f"--unmix_myco no \
     --output_dir {args.test_module}_test \
     --kraken_db {os.path.join(cwd, 'k2_pluspf_16gb_20210517/')} \
     --bowtie2_index {os.path.join(cwd, 'hg19_1kgmaj/')} \
     --bowtie_index_name hg19_1kgmaj"

    runline = f"{rl1} {pattern} {rl2}"
    subprocess.run(runline, shell=True)

def isDir(dirpath):
    """ checks directory exists
    """
    if not os.path.isdir(dirpath):

        msg = "{0} is not a directory".format(dirpath)
        raise argparse.ArgumentTypeError(msg)

    else:
        return os.path.abspath(os.path.realpath(os.path.expanduser(dirpath)))

def parse_args(argv):

    parser = argparse.ArgumentParser()

    parser.add_argument('script_path', action='store', help=argparse.SUPPRESS)
    parser.add_argument('test_module', action='store',
     choices=['TM01', 'TM02', 'TM03', 'TM04', 'TM05', 'TM06', 'TM07', 'TM08', 'TM09', 'TM10'],
     help='The TM## code for the testing module to run.')

    parser.add_argument('-d', '--datasetDir', type=isDir, action='store', default="./datasets",
     help='Path to directory containing test datasets. Default=./')

    args = parser.parse_args(argv)

    return args

def main(tm):
    """ main func
    """

    args = parse_args(sys.argv)
    tmDir = isDir(os.path.join(args.datasetDir, args.test_module))

    runtest(args, tmDir)

if __name__=="__main__":
    main(sys.argv[1])
