#!/bin/bash
# v0.1 04-feb-2015
progetto="Ver20150204_base"

stampa_output=$1
utente=$2

if [ -z $progetto ] || [ -z $stampa_output ] || [ -z $utente ]
then
    exit 17
fi

tempin=input.txt
tempout=output.txt

eseguibile=`./find_exe_path.sh $progetto $utente`
if [ -z "$eseguibile" ]
then
    exit 18
fi

echo $3 > $tempin
echo $4 >> $tempin
echo $5 >> $tempin
echo $6 >> $tempin
echo $7 >> $tempin
cat $tempin | $eseguibile > $tempout
pattern=${@:8:$#-7}
grep "$pattern" $tempout &> /dev/null
ret=$?
#echo "grep \"$pattern\" $tempout"
if [ $stampa_output -eq 1 ] && [ $ret -ne 0 ]
then
    echo -e "\n-------------------------"
    cat $tempout
    echo "$pattern <== pattern"
    echo -e "\n-------------------------"
fi
rm $tempin
rm $tempout
exit $ret