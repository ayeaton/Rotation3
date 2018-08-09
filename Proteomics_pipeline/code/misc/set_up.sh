#!/bin/bash
#$ -S /bin/bash
#$ -N setup

pipeline_path=$1
database1=$2
database2=$3
database3=$4
database4=$5
database5=$6
database6=$7

cat $pipeline_path/database/ensembl_human_37.70/proteome.fasta  $pipeline_path/database/crap/proteome.fasta $database1 $database2 $database3 $database4 $database5 $database6 > $pipeline_path/database/proteome_cat.fasta

awk '/^>/ {printf("\n%s\n",$0);next; } { printf("%s",$0);} END {printf("\n");}' <$pipeline_path/database/proteome_cat.fasta>$pipeline_path/database/proteome.fasta
