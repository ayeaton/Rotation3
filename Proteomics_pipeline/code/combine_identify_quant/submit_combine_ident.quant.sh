#!/bin/bash
#$ -S /bin/bash
#$ -e combine_sh_error.txt
#$ -o out.txt
#$ -N combine_ident_quant
#$ -cwd

TCGAMGFpath=$2
platform=$3
taxon_label=$4
path=$5
pipeline_path=$6

echo $TCGAMGFpath
echo $platform
echo $taxon_label



mkdir -p $TCGAMGFpath/pipeline_ident_quant_combined 

current_dir=$1

Rscript $1/combine.identify.quant.a.R $TCGAMGFpath $TCGAMGFpath/pipeline_ident_quant_combined $platform $taxon_label

