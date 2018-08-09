#$ -cwd
#$ -S /bin/bash
#$ -N prot_pipe
#$ -l mem_free=4G
#$ -pe threaded 4
#$ -e logs/error_$TASK_ID.txt
#$ -o logs/stdout_$TASK_ID.txt


# - - - - - - - - - - - - - - - - - - - - -
# Set Current Directory, 
# and lock steps and parameter references
# - - - - - - - - - - - - - - - - - - - - -

current_dir=$(pwd)
chmod 0444 $current_dir/steps_freeze.txt
chmod 0444 $current_dir/parameters_freeze.txt

# - - - - - - - - - - - - - - - - - - - - -
# Read in parameters and set to variables
# - - - - - - - - - - - - - - - - - - - - -

while IFS=$'\t'; read params value unused; do eval $params=$value; done < parameters.txt


# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Variables for processing the data in parallel
# DO NOT CHANGE!
# This code is meant to assign one sample to the analysis
# by listing all of the files in a directory (inputDir)
# and then finding the Nth one in the list. N will be
# assigned by the $SGE_TASK_ID variable generated by
# the SGE cluster.
# Note: $SGE_TASK_ID will only be assigned if the flag
# -t is used and the job is submitted by 'qsub -t 1:N script.sh' From TOM
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Assign index variable
number=`expr $SGE_TASK_ID - 1`

num=`expr $SGE_TASK_ID`

# Generate ls of input files
directories=(${path}/*)

# Get fastq file from index variable
sub_dir=${directories[number]}

# Get the name of current working file
#BN=`basename $sequence .bam`


# Print diagnostics
echo "- - - - Diagnostics - - - - - - - - - - -"
echo "Number of slots: $NSLOTS"
echo "Number of hosts: $NHOSTS"
echo "Number in Queue: $QUEUE"
echo -e "OS type: $SGE_ARCH"
echo -e "Working on Task ID: "${SGE_TASK_ID}" "
echo -e "Working on file: "${directories[number]}" "
echo -e "Output directory: "${outputDir}" \n"
echo "Run parameters:"
hostname -f
date
pwd
echo -e "- - - - - - - - - - - - - - - - - - -  \n"


# - - - - - - - - - - - - - - - - - - - - -
# Read in steps file and execute
# - - - - - - - - - - - - - - - - - - - - -

while IFS=$''; read line ; do
	echo $line
	
	if [ "$num" -gt 1 ] 
	then
		if [[ "$line" = "write_taxonomy" ]]
		then
			qsub -q all.q -N taxonomy -cwd -e logs/error_$num.txt -o logs/stdout_$num.txt "$pipeline_path"/code/misc/write_taxonomy.sh "$taxon_label" "$pipeline_path" "$database_path1" \
				"$database_path2" "$database_path3" "$database_path4" "$database_path5" "$database_path6"
		fi	

		if [[ "$line" = "format_fasta" ]]
		then
			sleep 2m 
			qsub -hold_jid taxonomy -N set_up -q all.q -cwd -o logs/stdout_$num.txt -e logs/error_$num.txt "$pipeline_path"/code/misc/set_up.sh "$pipeline_path" "$database_path1" "$database_path2" \
				"$database_path3" "$database_path4" "$database_path5" "$database_path6"
		fi


		if [[ "$line" = "pgx_index" ]]
		then 
			sleep 2m
			qsub -hold_jid set_up -q all.q -cwd -e logs/error_$number.txt -o logs/stdout_$number.txt "$pipeline_path"/code/misc/makePGxindex.sh "$pipeline_path"
		fi
	fi

	if [[ "$line" = "XTandem" ]]
	then
		if [ -s $pipeline_path/logs/error_$num.txt ]
        	then
            		echo "error.txt file is not empty. Please check the taxonomy, set_up, or pgx_index step"
                	echo "Error: XTandem step error.txt file is not empty. Please check the Xtandem step" 1>&2
                	exit 64
        	else   
			sleep 2m
			qsub -hold_jid set_up,pgx_index,taxonomy -N XTandem -q all.q -cwd -o logs/stdout_$num.txt -e logs/error_$num.txt "$pipeline_path"/code/Xtandem/submit_xtandem.sh \
			"$pipeline_path" "$sub_dir" "$taxon_label" "$precursor_mass_error_ppm" "$fragment_mass_error_ppm" "$fixed_mods" "$potential_mods" \
        		"$db_path" "$pipeline_path" "$platform"
		fi
	fi

	
	if [[ "$line" = "parse_XTandem" ]]
	then

		if [ -s $pipeline_path/logs/error_$num.txt ]
                then
                        echo "error.txt file is not empty. Please check the Xtandem step"
                        echo "Error: XTandem step error.txt file is not empty. Please check the Xtandem step" 1>&2
                        exit 64
                else
			sleep 5m
                        outputDirs=(${sub_dir}/${taxon_label}*)
                        echo $outputDirs
                        outputDir=${outputDirs[0]}

			qsub -hold_jid XTandem,ATCGA* -N parse_XTandem -q all.q -cwd -e logs/error_$num.txt -o logs/stdout_$num.txt $pipeline_path/code/parseXtandem/submit_parse_xtandem.sh $pipeline_path/code/parseXtandem \
			$outputDir $path $platform $taxon_label $pipeline_path
			echo "PARSE"			
                	for j in $outputDir/*.e*; do
                        	if [ -s $j ]
                        	then
                                	echo "Error: Files from the two XTandem steps are not empty Please check the Xtandem and parseXtandem steps. Error was found in $j"
                                	echo "Error: Files from the two XTandem steps are not empty Please check the Xtandem and parseXtandem steps. Error was found in $j" 1>&2
                                	exit 64
                        	else 
                        	        echo "empty"
				fi
                        done
		fi
	fi
	

	if [[ "$line" = "mgf_selector" ]]
	then
		if [ -s $pipeline_path/logs/error_$num.txt ]
                then
                    	echo "error.txt file is not empty. Please check the Xtandem step"
                        echo "Error: XTandem step error.txt file is not empty. Please check the Xtandem step" 1>&2
                        exit 64
                else

			qsub -hold_jid parse_XTandem,XTandem -N MGF -q all.q -cwd -o logs/stdout_$num.txt -e logs/error_$num.txt $pipeline_path/code/mgf_select/submit_mgf_selector.sh $pipeline_path $sub_dir \
			$mz_error $platform $min_intensity $min_reporters $pipeline_path $path $taxon_label
		fi	
	fi
	

	if [[ "$line" = "combine_ident.quant" ]]
	then
                if [ -s $pipeline_path/logs/error_$num.txt ]
                then
                    	echo "error.txt file is not empty. Please check the Xtandem step"
                        echo "Error: XTandem step error.txt file is not empty. Please check the Xtandem step" 1>&2
                        exit 64
                else
			qsub -hold_jid MGF,parse_XTandem,XTandem -N combine_ident -q all.q -cwd -e logs/error_$num.txt -o logs/stdout_$num.txt $pipeline_path/code/combine_identify_quant/submit_combine_ident.quant.sh \
			$pipeline_path/code/combine_identify_quant $sub_dir \
			$platform $taxon_label $path $pipeline_path
		fi
	fi

	
	if [[ "$line" = "combine_fractions" ]]
	then
		if [ -s $pipeline_path/logs/error_$num.txt ]
                then
                    	echo "error.txt file is not empty. Please check the Xtandem step"
                        echo "Error: XTandem step error.txt file is not empty. Please check the Xtandem step" 1>&2
                        exit 64
                else
                        qsub -hold_jid combine_ident,MGF,parse_XTandem,XTandem -N combine_fractions -q all.q -cwd -o logs/stdout_$num.txt -e logs/error_$num.txt "$pipeline_path"/code/combine_fraction/combine_fractions.sh \
			"$path" "$pipeline_path"
		fi
        fi


	if [[ "$line" = "pgx_assign_protein" ]]
	then
                if [ -s $pipeline_path/logs/error_$num.txt ]
                then
                    	echo "error.txt file is not empty. Please check the Xtandem step"
                        echo "Error: XTandem step error.txt file is not empty. Please check the Xtandem step" 1>&2
                        exit 64
            	else
                        qsub -hold_jid combine_fractions,combine_ident,MGF,parse_XTandem,XTandem -N pgx -q all.q -cwd -e logs/error_$num.txt -o logs/stdout_$num.txt \
			$pipeline_path/code/pgx/pgx_assign_protein_a.sh $path $sub_dir $dbpath \
			$pipeline_path $pipeline_path
		fi
	fi    
	
	if [[ "$line" = "quality" ]]
	then
		if [ -s $pipeline_path/logs/error_$num.txt ]
                then
                    	echo "error.txt file is not empty. Please check the Xtandem step"
                        echo "Error: XTandem step error.txt file is not empty. Please check the Xtandem step" 1>&2
                        exit 64
                else
			
			qsub -hold_jid pgx,combine_fractions,combine_ident,MGF,parse_XTandem,XTandem -N mgffile -q all.q -cwd -e logs/error_$num.txt -o logs/stdout_$num.txt \
			$pipeline_path/code/extract_quality/create_MGF_filename.sh $sub_dir $pipeline_path/code/extract_quality
			
			qsub -hold_jid mgffile,pgx,combine_fractions,combine_ident,MGF,parse_XTandem,XTandem -N extract_Q -q all.q -cwd -e logs/error_$num.txt -o logs/stdout_$num.txt \
			$pipeline_path/code/extract_quality/extract_quality.sh $pipeline_path/code/extract_quality/ $sub_dir/ $pipeline_path/code/extract_quality
			
			outputDirs=(${sub_dir}/pipeline_ident_quant_combined/quality_table/)
                        echo $outputDirs
                        for j in $outputDirs/*.e*; do
                                if [ -s $j ]
                                then
                                        echo "Error: Files from the quality filter steps are not empty Please check the quality steps. Error was found in $j"
                                        echo "Error: Files from the two quality filter steps are not empty Please check the quality steps. Error was found in $j" 1>&2
                                        exit 64
                                else
                                        echo "empty"
                                fi
                        done

			sleep 5m
			qsub -hold_jid TCGA*,extract_Q,mgffile,pgx,combine_fractions,combine_ident,MGF,parse_XTandem,XTandem -N merge_extract -q all.q -cwd -e logs/error_$num.txt -o logs/stdout_$num.txt \
			$pipeline_path/code/merge_out/merge_out.sh $sub_dir/ $pipeline_path/code/merge_out
		fi
	fi
done < steps.txt



              
