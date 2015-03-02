#!/bin/bash
echo "v0.2 - 16-feb-2015"
repository=$1
githubusers=$2
tokenfile=$3
if [ -z $repository ] || [ -z $githubusers ]
then
	echo "ERROR: missing parameter"
	echo "$0 <repository> <githubusers_filename>"
	exit 1
fi

temp=output.txt
curdir=`pwd`
errorreport="$curdir/${githubusers:0:${#githubusers}-4}_create_correzione.err"
rm $errorreport &> /dev/null

rm $newusers &> /dev/null

branch=correzione

n=0
s=0
while read u;
do
	n=$((n+1))
	cd $u/$repository/
	if [ $? -eq 0 ]
	then
                # Verifico esistenza ramo miasoluzione
                
                git checkout -b $branch &> "$temp"
                if [ $? -eq 0 ]
                then
                    s=$((s+1))
                    echo "==> $n: $u/$repository $branch created and checkout out"
                else
                    echo "==> $n: ERROR: $u/$repository failed creating branch $branch"
                    echo "$u/$repository failed creating and checking out $branch" >> "$errorreport"
                fi                
		cd ../..
	else
		echo "==> $n: ERROR: unable to find dir $u"
		echo "$u unable to find dir" >> "$errorreport"
	fi
done < $githubusers
echo "$n users read - $s repositories successfully branched ($branch)"
