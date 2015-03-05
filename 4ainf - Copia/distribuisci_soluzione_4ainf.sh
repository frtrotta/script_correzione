#!/bin/bash
echo "v0.2 - 16-feb-2015"
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

studenti_dir='/c/Users/frtrotta/Documents/Projects/githubstudenti/4ainf'
output_file="$studenti_dir/$repository.output.txt"
docente_dir='/c/Users/frtrotta/Documents/Projects/'

n=0
reference_repo="$docente_dir/$repository"
while read u;
do
    n=$((n+1))
    echo ; echo "$n: $u"
    current_repo="$studenti_dir/$u/$repository"

    cd $current_repo >$output_file 2>&1
    ret=$?
    if [ $? -ne 0 ]
    then
            read -p "Rilevato errore ($ret)"
    fi

    git checkout -b soluzione >>$output_file 2>&1
    ret=$?
    if [ $? -ne 0 ]
    then
            read -p "Rilevato errore ($ret)"
    fi
    
    cd $reference_repo >>$output_file 2>&1
    ret=$?
    if [ $? -ne 0 ]
    then
            read -p "Rilevato errore ($ret)"
    fi
    
    git archive soluzione | tar -x -C "$current_repo" >>$output_file 2>&1
    ret=$?
    if [ $? -ne 0 ]
    then
            read -p "Rilevato errore ($ret)"
    fi
    
    cd $current_repo >>$output_file 2>&1
    ret=$?
    if [ $? -ne 0 ]
    then
            read -p "Rilevato errore ($ret)"
    fi
    
    git commit -a -m 'Soluzione di riferimento' >>$output_file 2>&1
    ret=$?
    if [ $? -ne 0 ]
    then
            read -p "Rilevato errore ($ret)"
    fi
    
    git push origin soluzione >>$output_file 2>&1
    ret=$?
    if [ $? -ne 0 ]
    then
            read -p "Rilevato errore ($ret)"
    fi

    echo "==> Completed"
done < $githubusers
echo "$n users read"
rm $output_file
