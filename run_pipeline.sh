#!/bin/bash
#$ -S /bin/bash
#$ -cwd

current_dir=$(pwd)

chmod 0444 $current_dir/steps_freeze.txt
chmod 0444 $current_dir/parameters_freeze.txt


while IFS=$'\t'; read params value unused; do eval $params=$value; done < parameters.txt 


zero=0
COUNT=0
while IFS=$''; read line ; do

	if [[ "$line" = "write_taxonomy" ]]
	then
		qsub -q all.q -e "$current_dir"/code/misc/error.txt -o "$current_dir"/code/misc/out.txt \
			"$current_dir"/code/misc/write_taxonomy.sh "$taxon_label" "$pipeline_path" "$database_path1" \
			"$database_path2" "$database_path3" "$database_path4" "$database_path5" "$database_path6"
	fi

	
	if [[ "$line" = "format_fasta" ]]
	then
		sleep 2m 
		qsub -q all.q -e "$current_dir"/code/misc/error.txt -o "$current_dir"/code/misc/out.txt \
			"$current_dir"/code/misc/set_up.sh "$pipeline_path" "$database_path1" "$database_path2" \
			"$database_path3" "$database_path4" "$database_path5" "$database_path6"
	fi


	if [[ "$line" = "pgx_index" ]]
	then 
		sleep 2m
		qsub -q all.q -e "$current_dir"/code/misc/error.txt -o "$current_dir"/code/misc/out.txt \
			"$current_dir"/code/misc/makePGxindex.sh "$pipeline_path"
	fi


	if [[ "$line" = "XTandem" ]]
	then
		sleep 2m
		qsub -hold_jid pgx_ind,taxon,setup -q all.q -e "$current_dir"/code/Xtandem/error.txt -o "$current_dir"/code/Xtandem/out.txt \
			"$current_dir"/code/Xtandem/run_XTandem.sh "$path" "$taxon_label" "$pipeline_path" \
			"$precursor_mass_error_ppm" "$fragment_mass_error_ppm" "$fixed_mods" "$potential_mods" "$platform"
	fi

	
	if [[ "$line" = "parse_XTandem" ]]
	then
		if [[ "$COUNT" == "$zero" ]]
		then
			qsub -q all.q -e "$current_dir"/code/parseXtandem/error.txt -o "$current_dir"/code/parseXtandem/out.txt \
				"$current_dir"/code/parseXtandem/run_parse_XTandem.sh "$path" "$taxon_label" "$pipeline_path" "$platform"
		fi
	fi
	

	if [[ "$line" = "mgf_selector" ]]
	then
		qsub -q all.q -e "$current_dir"/code/mgf_select/error.txt -o "$current_dir"/code/mgf_select/out.txt \
			"$current_dir"/code/mgf_select/run_mgf_selector.sh "$path" "$platform" "$pipeline_path" "$mz_error" "$min_intensity" "$min_reporters" "$taxon_label"
	fi
	

	if [[ "$line" = "combine_ident.quant" ]]
	then
		if [[ "$COUNT" == "$zero" ]]
		then
			qsub -q all.q -e "$current_dir"/code/combine_identify_quant/error.txt -o "$current_dir"/code/combine_identify_quant/out.txt \
				"$current_dir"/code/combine_identify_quant/run_combine_ident.quant.sh "$path" "$platform" "$taxon_label" "$pipeline_path"
		fi
	fi

	
	if [[ "$line" = "combine_fractions" ]]
	then
                if [[ "$COUNT" == "$zero" ]]
		then
                        qsub -q all.q -e "$current_dir"/code/combine_fraction/error.txt -o "$current_dir"/code/combine_fraction/out.txt \
				"$current_dir"/code/combine_fraction/combine_fractions.sh "$path" "$pipeline_path"
		fi
        fi


	if [[ "$line" = "pgx_assign_protein" ]]
	then
                if [[ "$COUNT" == "$zero" ]]
		then
                        qsub -q all.q -e "$current_dir"/code/pgx/error.txt -o "$current_dir"/code/pgx/out.txt \
				"$current_dir"/code/pgx/run_pgxPassign_protein.sh "$path" "$pipeline_path"
		fi
        fi

	COUNT=$(( $COUNT + 1 ))
	echo "$COUNT"
done < steps.txt




