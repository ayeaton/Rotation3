#!/bin/bash
#$ -S /bin/bash
#$ -cwd

module load python/2.7.3

#pythondir=/ifs/home/wangx13/miniconda2/bin

python $3/extract_quality_psm_draw_dis.py $1 $2 pipeline_ident_quant_combined/ ITRAQ4pro 

##for i in /ifs/data/proteomics/projects/Xuya/CPTAC_GlobalProteome/MGF/breast/*TCGA*/; do qsub -q all.q -hard -l mem_free=3G extract_quality.sh /ifs/data/proteomics/projects/Xuya/CPTAC_GlobalProteome/pipeline/retrospective_cancers/scripts/ $i; done
##for i in /ifs/data/proteomics/projects/Xuya/CPTAC_GlobalProteome/MGF/ovarian/*TCGA*/; do qsub -q all.q -hard -l mem_free=3G extract_quality.sh /ifs/data/proteomics/projects/Xuya/CPTAC_GlobalProteome/pipeline/retrospective_cancers/scripts/ $i; done


