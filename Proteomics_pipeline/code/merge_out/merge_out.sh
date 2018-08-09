#!/bin/bash
#$ -S /bin/bash
#$ -cwd
module load python/2.7.3

sample_path=$1
pipeline_path=$2

echo $sample_path

python $pipeline_path/merge_out.py $sample_path


####for i in /ifs/data/proteomics/projects/Xuya/CPTAC_GlobalProteome/MGF/breast/*TCGA*/; do qsub -q all.q -hard -l mem_free=3G merge_out.sh $i; done
####for i in /ifs/data/proteomics/projects/Xuya/CPTAC_GlobalProteome/MGF/ovarian/*TCGA*/; do qsub -q all.q -hard -l mem_free=3G merge_out.sh $i; done


