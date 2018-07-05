#!/bin/bash
#$ -S /bin/bash
#$ -N flanks
#$ -cwd

while IFS=$'\t' read chr start end alu score strand source type dot geneIDtranscID unused; do 
        start_window=$((start - 350))
        end_window=$((end + 350)) 

        echo -e "$chr\t$start_window\t$start\t$alu\t$score\t$strand\t$source\t$type\t$dot\t$geneIDtranscID" >> /ifs/home/ay1392/ROT3/alu_pipe/alu_leading_flank350.bed
        echo -e "$chr\t$start\t$end\t$alu\t$score\t$strand\t$source\t$type\t$dot\t$geneIDtranscID" >> /ifs/home/ay1392/ROT3/alu_pipe/alu_meat350.bed
        echo -e "$chr\t$end\t$end_window\t$alu\t$score\t$strand\t$source\t$type\t$dot\t$geneIDtranscID" >> /ifs/home/ay1392/ROT3/alu_pipe/alu_trailing_flank350.bed
        echo -e "$chr\t$start_window\t$end_window\t$alu\t$score\t$strand\t$source\t$type\t$dot\t$geneIDtranscID" >> /ifs/home/ay1392/ROT3/alu_pipe/alu_arch_flank350.bed

done < /ifs/home/ay1392/ROT3/alu_pipe/alu_clean.bed
