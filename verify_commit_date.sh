#!/bin/bash
# v0.1 05-mar
repository=$1
date_time_after=$2
if [ -z "$repository" ] || [ -z "${date_time_after}" ]
then
	echo 'ERROR: missing parameter(s)'
	echo "Usage: $0 <repository> <date_time_after>"
	exit 100
fi
for utente in $(ls -d */)
do
	if [ -d "${utente}${repository}" ]
	then
		cd "${utente}${repository}"
		output=`git log --after="${date_time_after}"`
		if [ ! -z "$output" ]
		then
			echo $utente ============
			git log --after="${date_time_after}"
			echo ====================
		fi
		cd ../..
	fi
done
