#!/bin/bash
echo "v0.2 - 04-feb-2015"
repository=$1
githubusers=$2
tokenfile=$3
if [ -z $repository ] || [ -z $githubusers ] || [ -z $tokenfile ]
then
	echo "ERROR: missing parameter"
	echo "$0 <repository> <githubusers_filename> <token_filename>"
	exit 1
fi

token=`cat $tokenfile`
echo $token

temp=output.txt
curdir=`pwd`
errorreport="$curdir/${githubusers:0:${#githubusers}-4}_pushed.err"
rm $errorreport &> /dev/null

n=0
s=0
while read u;
do
	n=$((n+1))
	cd $u/$repository/
	if [ $? -eq 0 ]
	then
		git push --all &> "$temp"
		if [ $? -eq 0 ]
		then
			s=$((s+1))
			echo "==> $n: $u/$repository pushed all"
		else
			echo "==> $n: ERROR: $u/$repository failed pushing all"
			echo "$u/$repository failed pushing all" >> "$errorreport"
		fi
		cd ../..
	else
		echo "==> $n: ERROR: unable to find dir $u"
		echo "$u unable to find dir" >> "$errorreport"
	fi
done < $githubusers
echo "$n users read - $s repositories successfully all-pushed"
