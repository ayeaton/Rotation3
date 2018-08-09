#!/bin/bash
#$ -S /bin/bash
#$ -N parseXTandem

for i in /ifs/data/proteomics/projects/Anna/CPTAC/MGF/Ovarian/TCGA*; do Rscript /ifs/data/proteomics/projects/Anna/CPTAC/scripts/find_failed_jobs.R $i/ensembl_human_37_70_orf0_orf1_orf2_pipeline* .sh.e; done
