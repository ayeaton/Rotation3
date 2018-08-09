#!/bin/bash
#$ -S /bin/bash
#$ -cwd
#$ -N taxon

taxon_label=ensembl_human_37
pipeline_path=/ifs/data/proteomics/projects/Anna/pipeline_current
db_path=$pipeline_path/database

textFile="/ifs/data/proteomics/projects/Anna/Colorectal_dat/Colorectal_taxa.txt"

{
echo -e "<?xml version=\"1.0\"?>" 
echo -e	"<bioml label=\"x! taxon-to-file matching list\">"
echo -e "\t<taxon label=\""$taxon_label"\">" 
} > $db_path/taxonomy.xml

#for i in "${@:3}"; do
#	chrlen=${#i};
#		if [ $chrlen -gt 2 ]; 
#		then
#			echo -e "\t\t<file format=\"peptide\" URL=\"$i\" />" >> $db_path/taxonomy.xml 
#		fi
# done


while read line
do
	chrlen=${#line};
                if [ $chrlen -gt 2 ];
                then
                    	echo -e "\t\t<file format=\"peptide\" URL=\"$line\" />" >> $db_path/taxonomy.xml
                fi         
done < $textFile


echo -e "\t\t<file format=\"peptide\" URL=\""$pipeline_path"/database/ensembl_human_37.70/proteome.fasta\" />" >> $db_path/taxonomy.xml 
echo -e "\t\t<file format=\"mod\" URL=\""$pipeline_path"/database/ensembl_human_37.70/mods.xml\" />" >> $db_path/taxonomy.xml
echo -e "\t\t<file format=\"saps\" URL=\""$pipeline_path"/database/ensembl_human_37.70/saps.xml\" />" >> $db_path/taxonomy.xml

echo -e "\t\t<file format=\"peptide\" URL=\""$pipeline_path"/database/crap/proteome.fasta\" />" >> $db_path/taxonomy.xml
echo -e "\t\t<file format=\"mod\" URL=\""$pipeline_path"/database/crap/crap_mod.xml\" />" >> $db_path/taxonomy.xml
echo -e "\t\t<file format=\"saps\" URL=\""$pipeline_path"/database/crap/crap_saps.xml\" />" >> $db_path/taxonomy.xml

echo -e "\t</taxon>" >> $db_path/taxonomy.xml
echo -e "</bioml>" >> $db_path/taxonomy.xml

