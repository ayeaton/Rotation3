
#!/bin/bash
#$ -S /bin/bash
#$ -N sort
#$ -cwd

outputDir=$1
BN=$2

sort -k1,1 -k2,2n ${outputDir}/${BN}.collapsed_meat350.bed > ${outputDir}/${BN}.collapsed_meat350_sort.bed
sort -k1,1 -k2,2n ${outputDir}/${BN}.collapsed_leading350.bed > ${outputDir}/${BN}.collapsed_leading350_sort.bed
sort -k1,1 -k2,2n ${outputDir}/${BN}.collapsed_trailing350.bed > ${outputDir}/${BN}.collapsed_trailing350_sort.bed

