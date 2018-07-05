#!/bin/bash
#$ -S /bin/bash



# - - - - - - - - - - - - - - - - - - - - -
# Load required modules and paths
# - - - - - - - - - - - - - - - - - - - - -

module load star/2.4.5a
toolpath=/local/apps/star/2.4.5a/bin/Linux_x86_64
star_index_path=/ifs/data/proteomics/projects/Anna/Retrotransp-transcription/Breast/aluY/align1/star_norm
outputpath=/ifs/data/proteomics/projects/Anna/Retrotransp-transcription/Breast/aluY/align1/star_norm
inputpath="/ifs/data/proteomics/projects/Anna/Retrotransp-transcription/Breast/aluY/fastq/Normals"

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
files=(${inputpath}/*.r1.fastq)


# Get fastq file from index variable
sequence_read1=${files[number]}


echo $sequence_read1

# Get the name of current working file
BN=`basename $sequence_read1 .sort.r1.fastq`

echo $BN

sequence_read2=${inputpath}/${BN}.sort.r2.fastq

#echo $sequence_read1
echo $sequence_read2

$toolpath/STAR \
--genomeDir $outputpath \
--readFilesIn $sequence_read1 $sequence_read2 \
--runThreadN 2 --outFilterMultimapScoreRange 1 \
--outFilterMultimapNmax 20 \
--outFilterMismatchNmax 1 \
--alignIntronMax 500000 \
--alignMatesGapMax 1000000 \
--sjdbScore 2 \
--alignSJDBoverhangMin 1 \
--genomeLoad NoSharedMemory \
--limitBAMsortRAM 0 \
--readFilesCommand cat \
--outFilterMatchNminOverLread 0.66 \
--outFilterScoreMinOverLread 0.66 \
--sjdbOverhang 100 \
--runRNGseed 777 \
--outMultimapperOrder Random \
--outSAMmultNmax 1 \
--outSAMstrandField intronMotif \
--outSAMattributes NH HI NM MD AS XS \
--outSAMtype BAM SortedByCoordinate \
--outSAMheaderHD @HD VN:1.4 \
--outFileNamePrefix $outputpath/${BN}.
