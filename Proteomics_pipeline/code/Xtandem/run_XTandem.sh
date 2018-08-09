#!/bin/bash
#$ -S /bin/bash
#$ -N run_XTandem
#$ -cwd

path=$1
taxon_label=$2
pipeline_path=$3
precursor_mass_error_ppm=$4
fragment_mass_error_ppm=$5
fixed_mods=$6
potential_mods=$7
platform=$8
current_dir=$(pwd)/code/Xtandem
db_path=$pipeline_path/database

while IFS=$'\t'; read params value unused; do eval $params=$value; done < $pipeline_path/parameters.txt 


echo $platform

cd $path
for i in */; do trim_i=${i%?}; qsub -q all.q -e "$current_dir"/error.txt -o "$current_dir"/out.txt "$current_dir"/submit_xtandem.sh \
	"$current_dir" "$path/$trim_i" "$taxon_label" "$precursor_mass_error_ppm" "$fragment_mass_error_ppm" "$fixed_mods" "$potential_mods" "$db_path" "$pipeline_path" "$platform"; done



