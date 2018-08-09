#!/bin/bash
#$ -S /bin/bash
#$ -cwd

current_dir=$1
mgf_path=$2
taxon_label=$3
precursor_mass_error_ppm=$4
fragment_mass_error_ppm=$5
fixed_mods=$6
potential_mods=$7
dbpath=$8
pipeline_path=$9
platform=$10

perl $current_dir/code/Xtandem/qsub_xtandem.pl $mgf_path $taxon_label $precursor_mass_error_ppm $fragment_mass_error_ppm $fixed_mods $potential_mods $dbpath


