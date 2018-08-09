#!/bin/bash
#$ -S /bin/bash
#$ -N combine_fractions
#$ -cwd

sub_dir=$1
pipeline_path=$2

pipeline=pipeline_ident_quant_combined

trim_i=${i%?}
echo $trim_i
header_file=$(ls $sub_dir/$pipeline/*.ident.quant.txt |head -1)
echo $header_file
head -1 $header_file > $sub_dir/$pipeline/allfraction.$sub_dir.txt;
tail -n +3 -q $path/$i$pipeline/$sub_dir*.ident.quant.txt  >> $path/$i$pipeline/allfraction.$sub_dir.txt;
	
