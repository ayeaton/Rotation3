#!/bin/bash
#$ -S /bin/bash
#$ -N combine_fractions
#$ -cwd

path=$1
pipeline_path=$2

cd $path
pipeline=pipeline_ident_quant_combined
for i in */;
do
	#trim_i=${i%?}
	trim_i2=${i:2}
	trim_i=${trim_i2%??????????????????????????????????????????}
	echo $trim_i
	header_file=$(ls $path/$i$pipeline/*.ident.quant.txt |head -1)
	BN=`basename $i`
	echo $header_file
	head -1 $header_file > $path/$i$pipeline/allfraction.${BN}.txt;
	tail -n +3 -q $path/$i$pipeline/$trim_i*.ident.quant.txt  >> $path/$i$pipeline/allfraction.${BN}.txt;
done
	
