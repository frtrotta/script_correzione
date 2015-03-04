#!/bin/bash
echo 'v1.1 - 04-mar-2015'
repository=$1
githubusers=$2
tokenfile=$3
if [ -z $repository ] || [ -z $githubusers ] || [ -z $tokenfile ]
then
	echo 'ERROR: missing parameter(s)'
	echo "$0 <repository> <githubusers_filename> <token_filename>"
	exit 1
fi

token=`cat $tokenfile`
echo "$token"

temp='output.txt'
curdir=`pwd`
errorreport="$curdir/${githubusers}_cloned.err"
rm $errorreport &> /dev/null

newusers="${repository}_cloned"
rm $newusers &> /dev/null

n=0
s=0
a=0
while read u;
do
	cd $u
	if [ $? -eq 0 ]
	then
                n=$((n+1))
                if [ -d "$repository" ] 
                then
                        a=$((a+1))
                        echo "==> $n: $u/$repository already cloned"
                        echo "$u" >> "$curdir/$newusers"
                else
                    git clone https://frtrotta:$token@github.com/$u/$repository &> $temp
                    if [ $? -eq 0 ]
                    then
                            s=$((s+1))
                            echo "==> $n: $u/$repository cloned"
                            echo "$u" >> "$curdir/$newusers"
                    else
                            echo "==> $n: ERROR: $u/$repository failed cloning"
                            echo "$u/$repository" >> "$errorreport"
                    fi
                fi
		cd ..
	else
		echo "==> $n: ERROR: unable to find dir $u"
		echo "$u unable to find dir\n" >> "$errorreport"
	fi
done < $githubusers
echo "$n users read - $s repositories successfully cloned - $a already cloned"
echo -e "\nUpdated users' list (including already cloned) in $newusers"
