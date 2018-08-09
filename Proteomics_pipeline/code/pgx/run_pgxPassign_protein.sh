#!/bin/bash
#$ -S /bin/bash
#$ -N pgx
#$ -cwd

path=$1
pipeline_path=$2
current_dir=$(pwd)/code/pgx
dbpath=$pipeline_path/database


if [ -s $pipeline_path/code/combine_fraction/error.txt ]
then
        echo "combine_fraction step error.txt file is not empty. Please check the combine_fraction step"
        echo "Error: combine_fraction step error.txt file is not empty. Please check the combine_fraction step" 1>&2
        exit 64
else
	cd $path
	for i in */; do qsub -q all.q -e $pipeline_path/code/pgx/error.txt -o $pipeline_path/code/pgx/out.txt $pipeline_path/code/pgx/pgx_assign_protein_a.sh $path $i $dbpath $current_dir $pipeline_path; done
	echo $i
fi
