#!/bin/bash
echo "v0.3 - 16-feb-2015"
repository=$1
branch=$2
githubusers=$3
tokenfile=$4
if [ -z $repository ] || [ -z $branch ] || [ -z $githubusers ] || [ -z $tokenfile ]
then
	echo "ERROR: missing parameter"
	echo "$0 <repository> <branch> <githubusers_filename> <token_filename>"
	exit 1
fi

token=`cat $tokenfile`
echo $token

temp=output.txt
curdir=`pwd`
errorreport="$curdir/${githubusers:0:${#githubusers}-4}_pulled.err"
rm $errorreport &> /dev/null

n=0
s=0
while read u;
do
	n=$((n+1))
	cd $u/$repository/
	if [ $? -eq 0 ]
	then
		git pull $branch > "$temp"
		if [ $? -eq 0 ]
		then
			s=$((s+1))
			echo "==> $n: $u/$repository fetched"
		else
			echo "==> $n: ERROR: $u/$repository failed fetching"
			echo "$u/$repository failed fetching\n" >> "$errorreport"
		fi
		cd ../..
	else
		echo "==> $n: ERROR: unable to find dir $u"
		echo "$u unable to find dir" >> "$errorreport"
	fi
done < $githubusers
echo "$n users read - $s repositories successfully pulled"
