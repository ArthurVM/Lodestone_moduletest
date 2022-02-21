"""
junky and primitive install module for Lodestone_modtest
"""

import sys
import shutil
import re
import time
import argparse
from signal import alarm, signal, SIGALRM, SIGKILL
from subprocess import PIPE, Popen
from os import kill, path, chdir, getcwd, path, mkdir

## begin overengineered command executing class structure ##

class Error(Exception):
    """ Base class for exceptions in this module.
    """
    pass

class InputError(Error):
    """ Exception raised for errors in the input.

    Attributes:
        expression -- input expression in which the error occurred
        message -- explanation of the error
    """

    def __init__(self, expression, message):
        self.expression = expression
        self.message = message

        sys.stderr.write(f"INPUT ERROR : {self.expression}\n{self.message}")
        sys.exit(1)

class command():
    """ A class for handling shell executed commands
    TODO: clean up this class
    """
    def __init__(self, command):
        self.command = command
        print(f"COMMAND={self.command}")

    def run(self, timeout = -1):
        kill_tree = True

        class Alarm(Exception):
            pass

        def alarm_handler(signum, frame):
            raise Alarm

        p=Popen(self.command, shell = True, stdout = PIPE, stderr = PIPE, env = None)

        if timeout != -1:
            signal(SIGALRM, alarm_handler)
            alarm(timeout)

        try:
            stdout, stderr = p.communicate()
            if timeout != -1:
                alarm(0)

        except Alarm as a:
            pids = [p.pid]
            if kill_tree:
                pids.extend(self.get_process_children(p.pid))
            for pid in pids:
                # This is to avoid OSError: no such process in case process dies before getting to this line
                try:
                    kill(pid, SIGKILL)
                except OSError:
                    pass
            return -1, '', ''

        return p.returncode, stdout, stderr

    def run_comm(self, if_out_return, exit=True):
        """ Run the command with or without an exit code
        """
        returncode, stdout, stderr=self.run(360000)

        if returncode and stderr:
            sys.stderr.write(f"\nERROR: {self.command} FAILED!!! \n\nSTDERR: {stderr}\nSTDOUT: {stdout}\n")
            if exit:
                sys.exit(1)

        if if_out_return:
            return stdout

    def get_process_children(self, pid):
        p = Popen(f"ps --no-headers -o pid --ppid {pid}", shell = True,
	         stdout = PIPE, stderr = PIPE)
        stdout, stderr = p.communicate()
        return [int(p) for p in stdout.split()]

## end overengineered command executing class structure ##

def setupWD(args):
    """
    Constructs the testing environment.
    """
    rootdir = getcwd()

    ## download lodestone from git
    gitline = "git clone https://github.com/Pathogen-Genomics-Cymru/tb-pipeline.git"
    command(gitline).run_comm(0)

    ## prepare kraken2 database
    if not args.krakenDB:
        mkdir(f"{rootdir}/k2_standard_16gb_20200919/")
        chdir(f"{rootdir}/k2_standard_16gb_20200919/")

        print("Downloading Kraken2 DB from https://genome-idx.s3.amazonaws.com/kraken/k2_standard_16gb_20200919.tar.gz ...")
        getline = "curl -fsSL https://genome-idx.s3.amazonaws.com/kraken/k2_standard_16gb_20200919.tar.gz | tar -xz"
        command(getline).run_comm(0)

        chdir(rootdir)
    else:
        lnline = f"ln -s {args.krakenDB} ./"
        command(lnline).run_comm(0)

    ## prepare bowtie2 database
    if not args.bowtieIndex:
        mkdir(f"{rootdir}/hg19_1kgmaj")
        chdir(f"{rootdir}/hg19_1kgmaj/")

        print("Downloading bowtie2 DB from ftp://ftp.ccb.jhu.edu/pub/data/bowtie2_indexes/hg19_1kgmaj_bt2.zip ...")
        getline = "curl -fsSL ftp://ftp.ccb.jhu.edu/pub/data/bowtie2_indexes/hg19_1kgmaj_bt2.zip -o hg19_1kgmaj_bt2.zip ; unzip hg19_1kgmaj_bt2.zip"
        command(getline).run_comm(0)

        chdir(rootdir)
    else:
        lnline = f"ln -s {args.bowtieIndex} ./"
        command(lnline).run_comm(0)

    ## link datasets to module test directory
    datalnline = f"ln -s {args.testdata} ./datasets"
    command(datalnline).run_comm(0)

    ## link main scripts to module test directory
    mainlnline = f"ln -s {rootdir}/testing_modules/mainscripts/* ./tb-pipeline/"
    command(mainlnline).run_comm(0)

    ## link module scripts to module test directory
    modlnline = f"ln -s {rootdir}/testing_modules/ ./tb-pipeline/"
    command(modlnline).run_comm(0)

    if args.buildSingularityimg:
        chdir("./tb-pipeline/singularity/")
        buildline = "bash singularity_build.sh"
        command(buildline).run_comm(0)
        chdir(bd)

    print("INSTALLATION FINISHED. Could have gone well, could have been catastrophic. Good luck.")

def isDir(dirpath):
    """ checks directory exists
    """
    if not path.isdir(dirpath):

        msg = "{0} is not a directory".format(dirpath)
        raise argparse.ArgumentTypeError(msg)

    else:
        return path.abspath(path.realpath(path.expanduser(dirpath)))

def parse_args(argv):

    parser = argparse.ArgumentParser()

    parser.add_argument('script_path', action='store', help=argparse.SUPPRESS)
    parser.add_argument('testdata', action='store', type=isDir,
     help='Path to a directory containing test data.')

    parser.add_argument('-b', '--bowtieIndex', type=isDir, action='store', default=False,
     help='Path to the bowtie index if stored locally.')
    parser.add_argument('-k', '--krakenDB', type=isDir, action='store', default=False,
     help='Path to the kraken2 database if stored locally.')
    parser.add_argument('-s', '--buildSingularityimg', action='store_true', default=False,
     help='Build the Lodestone Singularity images. Default=False.')

    args = parser.parse_args(argv)

    return args

def main(argv):
    args = parse_args(argv)

    setupWD(args)

if __name__=="__main__":
    main(sys.argv)
