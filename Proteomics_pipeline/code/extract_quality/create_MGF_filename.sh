#!/bin/bash
#$ -S /bin/bash
#$ -cwd
#$ -N mgffilename

sample_path=$1
pipeline_path=$2

ls $sample_path/*.mgf > $sample_path/MGF_filename.txt

$pipeline_path/MGF_filename.R $sample_path
