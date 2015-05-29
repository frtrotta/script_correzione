#!/bin/bash
echo "v1.2 - 14-mar-2015"
repository=$1
if [ -z $repository ]
then
	echo "ERROR: missing parameter"
	echo "$0 <repository>"
	exit 1
fi

# Finding of githubusers file
# First tries with the compiled_soluzione
githubusers="${repository}_cloned_miasoluzione"
if [ ! -f "${githubusers}" ]
then
	# then tries with just compiled
	githubusers="${repository}_cloned"
	if [ ! -f "${githubusers}" ]
	then
		echo "ERROR: unable to find githubusers file"
		exit 2
	fi
fi
echo "$githubusers"

sn=`basename $0`
temp="${sn}.output.txt"
curdir=`pwd`
errorreport="$curdir/${githubusers}_${sn}.err"
rm $errorreport &> /dev/null

newusers="${githubusers}_compiled"
rm $newusers &> /dev/null

n=0
c=0
while read u;
do
	n=$((n+1))
    directory="$u/$repository/"
	if [ -d "$directory" ]
	then
		cd $directory
		make -f "nbproject/Makefile-Debug.mk" &> $temp
		if [ $? -eq 0 ]
		then
			c=$((c+1))
			echo -e "$n: $u\tOK"
            echo "$u" >> "$curdir/$newusers"
		else
			echo -e "$n: $u\tERROR (failed compiling)"
			echo "$u ERROR (failed compiling)" >> "$errorreport"
		fi
		cd ../..
	else
		echo "$n: $u\tERROR (unable to find directory $directory)"
		echo "$u ERROR (unable to find directory $directory)" >> "$errorreport"
	fi
done < $githubusers
echo "$n users read - $c repositories successfully compiled"
echo -e "\nUpdated users' list in $newusers"
