#!/bin/bash
#$ -S /bin/bash
#$ -N pgx_ind

pipeline_path=$1

python $pipeline_path/code/misc/pgx_index.py $pipeline_path/database
