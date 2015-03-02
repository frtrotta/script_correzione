# v0.2 27-gen-2015
stampa_output=$1
u=$2
tempin=input.txt
tempout=output.txt
eseguibile_trovato=1
eseguibile="$u/Ese001-SuperCalcolatore/dist/Debug/Cygwin_4.x-Windows/ese001-supercalcolatore.exe"
ls $eseguibile &> /dev/null
if [ $? -ne 0 ]
then
    # alcuni studenti hanno un altro nome di eseguibile...
    eseguibile="$u/Ese001-SuperCalcolatore/dist/Debug/Cygwin_4.x-Windows/ese001.exe"
    ls $eseguibile &> /dev/null
    if [ $? -ne 0 ]
    then
        eseguibile="$u/Ese001-SuperCalcolatore/dist/Debug/Cygwin_4.x_1-Windows/ese001.exe"
        ls $eseguibile &> /dev/null
        if [ $? -ne 0 ]
        then
            exit 117
        fi
    fi
fi

echo $3 > $tempin
echo $4 >> $tempin
echo $5 >> $tempin
cat $tempin | $eseguibile > $tempout
#grep $5 $tempout &> /dev/null
pattern=${@:6:$#-5}
grep "$pattern" $tempout &> /dev/null
#grep "$pippo" $tempout
ret=$?
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