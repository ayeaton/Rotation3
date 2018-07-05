#!/bin/bash
#$ -S /bin/bash
#$ -N paste
#$ -cwd

inputDir=$1
BN=$2
outputDir=$3
alu_pathDir=$4

cd ${outputDir}

paste ${outputDir}/${BN}.collapsed_leading350_sort.bed ${outputDir}/${BN}.collapsed_meat350_sort.bed ${outputDir}/${BN}.collapsed_trailing350_sort.bed |awk -F $'\t' -v BN="${BN}" '{ \
if($24 == 0)
printf("%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n", \
$1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, $18, $19, $20, $21, $22, $23, $24, $16) > (BN".paste.bed")
else
printf("%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n", \
$1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, $18, $19, $20, $21, $22, $23, $24, $16/(($8 + $24)/2)) > (BN".paste.bed")
}'
