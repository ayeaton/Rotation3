#!/bin/bash
#$ -S /bin/bash
#$ -N intersect
#$ -cwd

module load bedtools

alu_pipeDir=$4

inputBam=$1
BN=$2
outputDir=$3

echo $inputBam
echo $BN

bedtools genomecov -bga -ibam ${inputBam} > ${outputDir}/${BN}.bedgraph

wait

bedtools intersect -wb -bed -a ${outputDir}/${BN}.bedgraph -b $alu_pipeDir/alu_leading_flank350.bed > ${outputDir}/${BN}.alu_leading_flank350.bed 
bedtools intersect -wb -bed -a ${outputDir}/${BN}.bedgraph -b $alu_pipeDir/alu_meat350.bed > ${outputDir}/${BN}.alu_meat350.bed 
bedtools intersect -wb -bed -a ${outputDir}/${BN}.bedgraph -b $alu_pipeDir/alu_trailing_flank350.bed > ${outputDir}/${BN}.alu_trailing_flank350.bed  
#bedtools intersect -wb -bed -a ${outputDir}/${BN}.bedgraph -b $alu_pipeDir/alu_arch_flank350.bed > ${outputDir}/${BN}.alu_arch_flank350.bed 
