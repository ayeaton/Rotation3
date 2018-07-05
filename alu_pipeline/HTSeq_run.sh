#!/bin/bash
#$ -cwd
#$ -S /bin/bash
#$ -N HTseq
#$ -l mem_free=4G
#$ -pe threaded 4
#$ -e logs/error_$TASK_ID.txt
#$ -o logs/stdout_$TASK_ID.txt


module load samtools
module load igenomes

toolpath=/local/apps/star/2.4.5a/bin/Linux_x86_64
inputDir=/ifs/data/proteomics/projects/Anna/Retrotransp-transcription/Breast/aluY/align1/star_norm
gtf=/ifs/home/ay1392/ROT3/files_in_use/hg38_genes_Alu.gtf
outputDir=/ifs/data/proteomics/projects/Anna/Retrotransp-transcription/Breast/aluY/HTseq/norm

# Assign index variable
number=`expr $SGE_TASK_ID - 1`

# Generate ls of input files
files=(${inputDir}/*.bam)

# Get fastq file from index variable
sample=${files[number]}

BN=`basename $sample .bam`

echo $sample

htseq-count --format=bam -r pos --nonunique=all -i gene_id $sample $gtf > $outputDir/$BN
