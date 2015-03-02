echo "v0.2 - 27-gen-2015"
studente=$1
stampa_output=$2
script_verifica=./verifica_Ese003.sh
input_file=input_Ese003.txt
if [ -z $studente ] || [ -z $stampa_output ]
then
	echo "ERROR: missing parameter"
	echo "$0 <studente> <stampa_output>"
	exit 1
fi

i=1
while read input_line
do
    $script_verifica $stampa_output $studente $input_line
    ret=$?
    if [ $ret -eq 0 ]
    then
        echo "  Input $i OK"
    else
        if [ $ret -eq 117 ]
        then
            echo "  Eseguibile non trovato"
        else
            echo "  Input $i Errore"
        fi
    fi
    i=$((i+1))
done < $input_file