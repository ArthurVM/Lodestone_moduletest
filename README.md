# Lodestone_moduletest

Setup testing directory by running 

```python3 setupWD.py```

```
$> python3 setupWD.py -h
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
