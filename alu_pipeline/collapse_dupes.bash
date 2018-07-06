#!/bin/bash
#$ -S /bin/bash
#$ -N collapse
#$ -cwd

inputDir=$1
BN=$2
outputDir=$3
alu_pathDir=$4
cd ${outputDir}

awk -v BN="${BN}" '
    NR>0{
        if($7 - $6 >= 300)
                print $18
                arr[$18] += $4
                count[$18] += 1
                chr[$18] = $5
                start[$18] = $6
                end[$18] = $7
                alu[$18] = $8
                alu_sub[$18] = $17
                alu_strand[$18] = $10   
    }
    END{
        for (a in arr) {
            print chr[a] "      " start[a] "    " end[a] "      " alu[a] "      " alu_sub[a] "  " alu_strand[a] "       " a "   " arr[a] / count[a] > (BN".collapsed_meat350.bed")
        }
    }
' ${outputDir}/${BN}.alu_meat350_cat.bed 


awk -v BN="${BN}" '
    NR>0{
        if($7 - $6 >= 300)
                arr[$18] += $4
                count[$18] += 1
                chr[$18] = $5
                start[$18] = $6
                end[$18] = $7
                alu[$18] = $8
                alu_sub[$18] = $17
                alu_strand[$18] = $10
    }
    END{
        for (a in arr) {
            print chr[a] "      " start[a] "    " end[a] "      " alu[a] "      " alu_sub[a] "  " alu_strand[a] "       " a "   " arr[a] / count[a] > (BN".collapsed_leading350.bed")
        }
    }
' ${outputDir}/${BN}.alu_leading_flank350_cat.bed


awk -v BN="${BN}" '
    NR>0{
        if($7 - $6 >= 300)
                arr[$18] += $4
                count[$18] += 1
                chr[$18] = $5
                start[$18] = $6
                end[$18] = $7
                alu[$18] = $8
                alu_sub[$18] = $17
                alu_strand[$18] = $10
    }
    END{
        for (a in arr) {
            print chr[a] "      " start[a] "    " end[a] "      " alu[a] "      " alu_sub[a] "  " alu_strand[a] "       " a "   " arr[a] / count[a] > (BN".collapsed_trailing350.bed")
        }
    }
' ${outputDir}/${BN}.alu_trailing_flank350_cat.bed
