#!/bin/bash
#$ -S /bin/bash
#$ -cwd
#$ -N parseXTandem

echo ".sh"
echo $2
echo $1/parse_xtandem_scan.pl
current_dir=$1
taxon_label_path=$2
path=$3
platform=$4
taxon_label=$5
pipeline_path=$6

echo "submit"
echo $1
echo $2
echo $3
echo $4 
echo $5
echo $6
echo $pipeline_path

perl $current_dir/parse_xtandem_scan.pl $taxon_label_path




