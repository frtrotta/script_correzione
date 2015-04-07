#!/bin/bash

echo 'v0.1 - 07-apr-2015'
githubusers=$1
if [ -z $githubusers ]
then
	echo 'ERROR: missing parameter(s)'
	echo "$0 <githubusers_filename>"
	exit 1
fi

while read user
do
	mkdir $user
	echo $user
done < "$githubusers"
