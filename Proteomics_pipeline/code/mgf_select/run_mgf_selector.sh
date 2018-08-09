#!/bin/bash
#$ -S /bin/bash
#$ -N mgf
#$ -cwd

path=$1
platform=$2
pipeline_path=$3
current_dir=$(pwd)/code/mgf_select
mz_error=$4
min_intensity=$5
min_reporters=$6
taxon_label=$7

if [ -s $pipeline_path/code/parseXtandem/error.txt ]
then
    	echo "parseXTandem step error.txt file is not empty. Please check the parseXtandem step"
        echo "Error: parseXTandem step error.txt file is not empty. Please check the parseXtandem step" 1>&2
        exit 64
else
	cd $path
	for i in */; do qsub -q all.q -e $current_dir/error.txt -o $current_dir/out.txt $current_dir/submit_mgf_selector.sh \
		$current_dir $path/$i $mz_error $platform $min_intensity $min_reporters $pipeline_path $path $taxon_label; done
fi


