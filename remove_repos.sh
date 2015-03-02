#!/bin/bash
echo "v0.2 - 27-gen-2015"
repository=$1
githubusers=$2

if [ -z $repository ] || [ -z $githubusers ]
then
	echo "ERROR: missing parameter(s)"
	echo "$0 <repository> <users_filename>"
	exit 1
fi

while read u;
do
	dir=$u/$repository/
	rm -fr $dir
	echo "$dir removed"
done < $githubusers
