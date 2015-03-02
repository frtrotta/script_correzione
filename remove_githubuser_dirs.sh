#!/bin/bash
echo "v0.2 - 27-gen-2015"
githubusers=$1

if [ -z $githubusers ]
then
	echo "ERROR: missing parameter"
	echo "$0 <users_filename>"
	exit 1
fi

while read u;
do
	rm -fr $u
	echo $u
done < $githubusers
