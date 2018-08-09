#!/bin/bash
#$ -S /bin/bash
#$ -N run_combine_idq
#$ -cwd

path=$1
platform=$2
current_dir=$(pwd)/code/combine_identify_quant
taxon_label=$3
pipeline_path=$4

if [ -s $pipeline_path/code/parseXtandem/error.txt ]
then
    	echo "parseXTandem step error.txt file is not empty. Please check the parseXtandem step"
        echo "Error: parseXTandem step error.txt file is not empty. Please check the parseXtandem step" 1>&2
        exit 64
else
	if [ -s $pipeline_path/code/mgf_select/error.txt ]
	then
    		echo "mgf_select step error.txt file is not empty. Please check the mgf_select step"
        	echo "Error: mgf_select step error.txt file is not empty. Please check the mgf_select step" 1>&2
        	exit 64
	else
		cd $path
		for i in */; do trim_i=${i%?}; qsub -q all.q -e $pipeline_path/code/combine_identify_quant/error.txt -o $pipeline_path/code/combine_identify_quant/out.txt $pipeline_path/code/combine_identify_quant/submit_combine_ident.quant.sh \
			$pipeline_path/code/combine_identify_quant $trim_i $platform $taxon_label $path $pipeline_path; echo $trim_i; done
	

	fi
fi
		

