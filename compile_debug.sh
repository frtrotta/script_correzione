#!/bin/bash
echo "v0.4 - 16-feb-2015"
repository=$1
githubusers=$2
if [ -z $repository ] || [ -z $githubusers ]
then
	echo "ERROR: missing parameter"
	echo "$0 <repository> <githubusers_filename>"
	exit 1
fi

temp='compile.output.txt'
curdir=`pwd`
errorreport="$curdir/${githubusers:0:${#githubusers}-4}_compiled.err"
rm $errorreport &> /dev/null

newusers="${githubusers:0:${#githubusers}-4}_compiled.txt"
rm $newusers &> /dev/null

n=0
c=0
while read u;
do
	n=$((n+1))
        directory=$u/$repository/
	cd $directory &> $temp
	if [ $? -eq 0 ]
	then
		make -f "nbproject/Makefile-Debug.mk" &> $temp
		if [ $? -eq 0 ]
		then
			c=$((c+1))
			echo -e "==> $n: $u/$repository\tcompiled"
                        echo "$u" >> "$curdir/$newusers"
		else
			echo -e "==> $n: ERROR: $u/$repository\tfailed compiling"
			echo "$u/$repository failed compiling" >> "$errorreport"
		fi
		cd ../..
	else
		echo "==> $n: ERROR: unable to find dir $directory"
		echo "$u unable to find dir $directory" >> "$errorreport"
	fi
done < $githubusers
echo "$n users read - $c repositories successfully compiled"
echo -e "\nUpdated users' list in $newusers"
