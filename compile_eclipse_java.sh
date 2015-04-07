#!/bin/bash
echo "v0.1 - 14-mar-2015"
repository=$1
java_file=$2
if [ -z $repository ] || [ -z ${java_file} ]
then
	echo "ERROR: missing parameter(s)"
	echo "$0 <repository> <java_file>"
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
		if [ ! -d bin/ ] ; then
			mkdir bin
		fi
		
		if [ -d src/ ]
		then
			javac -d bin/ -cp src src/${java_file} &> /dev/null
			#javac -d bin/ -cp src src/${java_file}
			# http://tldp.org/LDP/abs/html/string-manipulation.html
			case $? in
			0 )
				c=$((c+1))
				echo -e "$n: $u\tOK"
				echo "$u" >> "$curdir/$newusers"
				;;			
			1 )
				echo -e "$n: $u\tERROR (failed compiling) $r"
				echo "$u ERROR (failed compiling)" >> "$errorreport"
				;;
			2 )
				echo -e "$n: $u\tERROR (file not found)"
				echo "$u ERROR (file not found)" >> "$errorreport"
				#ls -R src/
				;;
			* )
				echo -e "$n: $u\tERROR (unkown error)"
				echo "$u ERROR (unkown error)" >> "$errorreport"
				;;
			esac
		else
			echo -e "$n: $u\tERROR (no src directory found)"
			echo "$u ERROR (no src directory found)" >> "$errorreport"
		fi
		cd ../..
	else
		echo "$n: $u\tERROR (unable to find directory $directory)"
		echo "$u ERROR (unable to find directory $directory)" >> "$errorreport"
	fi
done < $githubusers
echo "$n users read - $c repositories successfully compiled"
echo -e "\nUpdated users' list in $newusers"
