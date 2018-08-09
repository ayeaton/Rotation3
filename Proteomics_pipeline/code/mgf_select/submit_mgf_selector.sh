#!/bin/bash
#$ -S /bin/bash
#$ -N mgf_select
#$ -cwd 

MGF_folder=$2
Platform=$4
mz_error=$3
min_intensity=$5
min_reporters=$6
pipeline_path=$7
path=$8
taxon_label=$9


perl $1/code/mgf_select/mgf_select_reporter.pl $MGF_folder $mz_error $Platform $min_intensity $min_reporters


