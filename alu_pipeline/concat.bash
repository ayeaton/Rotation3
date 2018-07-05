#!/bin/bash
#$ -S /bin/bash
#$ -N concat
#$ -cwd

outputDir=$1
BN=$2

awk '{print $0,"\t",$5 "-" $6}' ${outputDir}/${BN}.alu_leading_flank350.bed > ${outputDir}/${BN}.alu_leading_flank350_cat.bed
awk '{print $0,"\t",$5 "-" $6}' ${outputDir}/${BN}.alu_meat350.bed > ${outputDir}/${BN}.alu_meat350_cat.bed
awk '{print $0,"\t",$5 "-" $6}' ${outputDir}/${BN}.alu_trailing_flank350.bed > ${outputDir}/${BN}.alu_trailing_flank350_cat.bed
#awk '{print $0,"\t",$5 "-" $6}' ${outputDir}/${BN}.alu_arch_flank350.bed > ${outputDir}/${BN}.alu_arch_flank350_cat.bed
