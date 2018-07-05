#!/bin/bash
#$ -S /bin/bash
#$ -N b2fstq

# - - - - - - - - - - - - - - - - - - - - -
# Load required environment
# - - - - - - - - - - - - - - - - - - - - -

module load samtools/1.7
module load bedtools

# - - - - - - - - - - - - - - - - - - - - -
# Set variables
# - - - - - - - - - - - - - - - - - - - - -

inputpath=/ifs/data/proteomics/projects/Anna/Retrotransp-transcription/Breast/aluY/sorted_BAM/Normals
outputfolder=/ifs/data/proteomics/projects/Anna/Retrotransp-transcription/Breast/aluY/fastq/Normals

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Variables for processing the data in parallel
# DO NOT CHANGE!
# This code is meant to assign one sample to the analysis
# by listing all of the files in a directory (inputDir)
# and then finding the Nth one in the list. N will be
# assigned by the $SGE_TASK_ID variable generated by
# the SGE cluster.
# Note: $SGE_TASK_ID will only be assigned if the flag
# -t is used and the job is submitted by 'qsub -t 1:N script.sh'
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Assign index variable
number=`expr $SGE_TASK_ID - 1`

# Generate ls of input files
files=(${inputpath}/*.sort.bam)

# Get fastq file from index variable
sequence=${files[number]}

# Get the name of current working file
BN=`basename $sequence .bam`

samtools fastq ${sequence} -1 ${outputfolder}/${BN}.r1.fastq -2 ${outputfolder}/${BN}.r2.fastq
