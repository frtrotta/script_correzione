#!/bin/bash
# v0.3 23-feb-2015
#
# Cerca il percorso dell'eseguibile, usando differenti nomi per le directory.
# Se trovato, restituisce il percorso _completo_ dell'eseguibile.
#
# directory contiene il percorso completo del progetto e termina col nome del
# progetto.

directory=$1

if [ -z $directory ]
then
    echo "ERROR: Missing parameter(s)"
    echo "$0 <directory>"
    exit 1
fi

project=`basename $directory`

# Make the toolchain array
declare -a toolchain
toolchain=("Cygwin_4.x-Windows" "Cygwin_4.x_1-Windows" "GNU-Linux-x86" "Cygwin-Windows")
#    for (( i = 0 ; i < ${#toolchain[@]} ; i++ ))
#    do
#        echo "toolchain[$i]: ${toolchain[$i]}"
#    done
#--------------------------

# Make the executable array
lowercase_project="${project,,}"
declare -a executable
j=0
executable[j]="${lowercase_project}.exe"
j=1
# extract up to the first dash
for (( i = 0 ; i < ${#lowercase_project} ; i++ ))
do
    if [ ${lowercase_project:i:1} == "-" ] 
    then
        break
    fi
done
if [ $i -lt $((${#lowercase_project} - 1)) ] 
then
    executable[$j]="${lowercase_project:0:i}.exe"
    echo 
fi

#    for (( i = 0 ; i < ${#executable[@]} ; i++ ))
#    do
#        echo "executable[$i]: ${executable[$i]}"
#    done
#--------------------------

r=2
for (( t = 0 ; t < ${#toolchain[@]} ; t++ ))
do
    for (( e = 0 ; e < ${#executable[@]} ; e++ ))
    do
        exe_path="${directory}/dist/Debug/${toolchain[$t]}/${executable[$e]}"
        #echo $exe_path
        if [ -x ${exe_path} ]
        then
            echo ${exe_path}
            r=0
            break
        fi
    done
done

exit $r
