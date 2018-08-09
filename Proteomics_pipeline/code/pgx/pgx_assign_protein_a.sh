#!/bin/bash
#$ -S /bin/bash


module load python/2.7.3

path=$1
i=$2 ##MGF folder
dbPath=$3/database
echo $i
pipeline_path=$4


file=(${i}/pipeline_ident_quant_combined/allfraction.*.txt)
#filename=allfraction.*.txt  ##either breast or ovarian allfraction.*.txt

echo $file

filename=`basename $file`

echo $filename
subdir=pipeline_ident_quant_combined

resultPath=$i/$subdir
filePrefix=allfraction.$(basename $i)

echo "PGX"

echo $resultPath
echo $resultPath/temp
echo $pipeline_path

mkdir -p $resultPath/temp

echo "First"
#read in file and generate uniq peptide sequence
python $pipeline_path/code/pgx/pgx_readin_files.py $resultPath $filename

echo "Second"
#analyze its protein group name with PGx

echo "Third"
python $pipeline_path/code/misc/pgx_query.py $resultPath/temp/$filePrefix.peptideList.csv $dbPath >$resultPath/temp/$filePrefix.peptideList.protein.csv

echo "Fourth"
#assign orignial file with multiProtein groups in one line
python $pipeline_path/code/pgx/pgx_collapse_byPep.py $resultPath/temp $filePrefix.peptideList.protein.csv $resultPath/$filename T




