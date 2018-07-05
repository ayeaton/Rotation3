#!/bin/bash
#$ -S /bin/bash


module load star/2.4.5a
toolpath=/local/apps/star/2.4.5a/bin/Linux_x86_64
star_index_path=/ifs/home/ay1392/ROT3/star_b


path=/ifs/data/proteomics/projects/Anna/Retrotransp-transcription/Breast/aluY/align1/Normals_SJ.out.tab
outputpath=/ifs/data/proteomics/projects/Anna/Retrotransp-transcription/Breast/aluY/align1/star_norm


hg38_genome=/ifs/home/ay1392/ROT3/files_in_use/hg38.fa
genes_alu_gtf=/ifs/home/ay1392/ROT3/files_in_use/hg38_genes_Alu.gtf


$toolpath/STAR --runMode genomeGenerate --genomeDir $outputpath --genomeFastaFiles "$hg38_genome" --sjdbOverhang 100 \
        --runThreadN 2 --limitSjdbInsertNsj 5000000 --sjdbFileChrStartEnd $path
