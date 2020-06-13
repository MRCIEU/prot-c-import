# Import Suhre et al 2017 pQTL dataset

Original data from here: http://metabolomics.helmholtz-muenchen.de/pgwas/index.php. It has been processed by EBI and saved here: ftp://ftp.ebi.ac.uk/pub/databases/gwas/summary_statistics/SuhreK_28240269_GCST004365/harmonised/. That data has everything on build 38, has effect and non-effect alleles, but it doesn't have standard errors. Need to calculate standard errors from the z-scores prior to processing.

## Define data location

Create a config file called `config.json` which looks like:

```
{
  "datadir": "/path/to/data/dir"
}
```


## Download files

Get the meta-data from original authors and the file list from EBI.

```
bash dl.sh
```

## Organise data

```
Rscript organise_metadata.r
```

Creates `/path/to/data/dir/ready/input.csv`, which defines the IDs for every file and column info etc.

```
Rscript organise_gwasdata.r
```

Updates the GWAS files to have SE etc and saves them to `/path/to/data/dir/ready/`.

## Run pipeline

At this point we have

1. All the files downloaded and formatted in `/path/to/data/dir/ready/`
2. A file called `/data/dir/ready/input.csv` which describes the data and specifies the metadata

We can now run the pipeline. Set it up:

```
module add languages/anaconda3/5.2.0-tflow-1.11
git clone --recurse-submodules git@github.com:MRCIEU/igd-hpc-pipeline.git
cd igd-hpc-pipeline/resources/gwas2vcf
python3 -m venv venv
source ./venv/bin/activate
./venv/bin/pip install -r requirements.txt
cd ../..
```



Some manual steps

```
datadir=$(jq -r .datadir ../config.json)

Rscript resources/metadata_to_json.r ${datadir}/ready/input.csv ${datadir}/ready ${datadir}/processed ${datadir}/ready/input_json.csv 8

Rscript resources/setup_directories.r ${datadir}/ready/input_json.csv 8

gwasdir="$(jq -r .datadir ../config.json)/processed"
echo `realpath ${gwasdir}` > gwasdir.txt
p=`pwd`
cd ${gwasdir}
ls --color=none -d * > ${p}/idlist.txt
cd ${p}
head idlist.txt
nid=`cat idlist.txt | wc -l`
echo "${nid} datasets"
```


Now run:

```
module add languages/anaconda3/5.2.0-tflow-1.11
snakemake -prk \
-j 400 \
--cluster-config bc4-cluster.json \
--cluster "sbatch \
  --job-name={cluster.name} \
  --partition={cluster.partition} \
  --nodes={cluster.nodes} \
  --ntasks-per-node={cluster.ntask} \
  --cpus-per-task={cluster.ncpu} \
  --time={cluster.time} \
  --mem={cluster.mem} \
  --output={cluster.output}"
```

