#!/bin/bash
# v1.0 04-mar-2015
#
# Cerca il percorso dell'eseguibile, usando differenti nomi per le directory.
# Se trovato, restituisce il percorso _assoluto_ dell'eseguibile.
#
# directory contiene il percorso completo del progetto e termina col nome del
# progetto.

directory=$1

if [ -z "$directory" ]
then
    echo "ERROR: Missing parameter(s)"
    echo "$0 <directory>"
    exit 1
fi

if [ "${directory:0:1}" != '/' ]
then
	temp=`pwd`
	cd "$directory"
	directory=`pwd`
	cd "$temp"
fi

# Make the toolchain array
declare -a toolchain
toolchain=("Cygwin_4.x-Windows" "Cygwin_4.x_1-Windows" "GNU-Linux-x86" "Cygwin-Windows")
#    for (( i = 0 ; i < ${#toolchain[@]} ; i++ ))
#    do
#        echo "toolchain[$i]: ${toolchain[$i]}"
#    done
#--------------------------

r=2
for (( t = 0 ; t < ${#toolchain[@]} ; t++ ))
do
	current_dir="${directory}/dist/Debug/${toolchain[$t]}"
	if [ -d "${current_dir}" ]
	then
		exe_path=`ls ${current_dir}/*.exe`
		if [ -x "${exe_path}" ]
		then
			echo ${exe_path}
			r=0
			break
		fi
	fi
done

exit $r
