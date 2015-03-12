#!/bin/bash

cat << FINE

v0.1 2015-03-12 FT
Anonimizza i file PNG scaricati come pacchetto di consegne da Moodle v2.8.
Crea il file lista.txt con la corrispondenza tra numero e nome dell'utente

FINE

ls | grep -i '.png' | awk -F'_' 'BEGIN {OFS=";"} { print $2, $1 }' | uniq > lista.txt
ls | grep -i '.png' > temp
while read clear_file_name
do
	n=`echo ${clear_file_name} | awk -F'_' '{ print $2 }'`
	f=`echo ${clear_file_name} | awk -F'_' '{ print $5 }'`
	if [ -n "$n" -a -n "$f" ]
	then
		mv "${clear_file_name}" "${n}_${f,,}"
		echo "${n}_${f}"
	else
		echo "ERROR: ${clear_file_name} -> n: $n --- f: $f"
	fi
done < temp
rm temp