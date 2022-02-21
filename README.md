# Lodestone_moduletest

## Setup testing directory 

Run
```python3 setupWD.py```

```
❯ python3 setupWD.py -h
usage: setupWD.py [-h] [-b BOWTIEINDEX] [-k KRAKENDB] [-s] testdata

positional arguments:
  testdata              Path to a directory containing test data.

optional arguments:
  -h, --help            show this help message and exit
  -b BOWTIEINDEX, --bowtieIndex BOWTIEINDEX
                        Path to the bowtie index if stored locally.
  -k KRAKENDB, --krakenDB KRAKENDB
                        Path to the kraken2 database if stored locally.
  -s, --buildSingularityimg
                        Build the Lodestone Singularity images. Default=False.

```

If -b and/or -k are not provided, it will attempt to download and unzip the required databases to the working directory.
NOTE: these databses are large, consequently this may be a time consuming process.

Since a new instance of the tb-pipeline will be cloned from github, the singularity images will also need to be built using the -s flag. If for some reason this is not required, this may be ommitted.

A directory containing test data must be provided, and structured as a root dataset directory containing subdirectories for each testing module, which in turn contain the testing datasets: 
```
dataset
├── TM01
├── TM02
├── TM03
├── TM04
├── TM05
├── TM06
├── TM07
├── TM08
├── TM09
└── TM10
```
which will be linked to the testing directory.

## Run Test

Within the `Lodestone_moduletest` root directory, run
```
python3 modtest.py TM##
```

```
❯ python3 modtest.py -h
usage: modtest.py [-h] [-d DATASETDIR] {TM01,TM02,TM03,TM04,TM05,TM06,TM07,TM08,TM09,TM10}

positional arguments:
  {TM01,TM02,TM03,TM04,TM05,TM06,TM07,TM08,TM09,TM10}
                        The TM## code for the testing module to run.

optional arguments:
  -h, --help            show this help message and exit
  -d DATASETDIR, --datasetDir DATASETDIR
                        Path to directory containing test datasets. Default=./
```
if -d is not provided, it will look for a directory named 'dataset' in the `Lodestone_moduletest` root directory.
