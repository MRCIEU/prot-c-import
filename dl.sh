#!/bin/bash

datadir=$(jq -r .datadir config.json)

echo $datadir
echo $(ls $datadir)

p=$(pwd)
mkdir -p ${datadir}/dl
cd ${datadir}/dl

# wget http://metabolomics.helmholtz-muenchen.de/pgwas/download/suhre.pgwas.koraf4.tar

wget http://metabolomics.helmholtz-muenchen.de/pgwas/download/probeanno.tsv

wget http://metabolomics.helmholtz-muenchen.de/pgwas/download/probeanno.json

# tar xvf suhre.pgwas.koraf4.tar

# rename "-" "_" *.out.gz
# rename "_one" "" *.out.gz


# Get EBI dataset
cat filelist.txt | parallel --jobs 10 "wget ftp://ftp.ebi.ac.uk/pub/databases/gwas/summary_statistics/SuhreK_28240269_GCST004365/harmonised/{}"


