echo "v0.2 - 27-gen-2015"
githubusers=$1
script_verifica=./verifica_Ese002.sh
input_file=input_Ese002.txt
if [ -z $githubusers ]
then
	echo "ERROR: missing parameter"
	echo "$0 <githubusers_filename>"
	exit 1
fi

i=1
while read u
do
    errore=0
    while read input_line
    do
        $script_verifica 0 $u $input_line
        errore=$?
        if [ $errore -ne 0 ]
        then
            break
        fi
    done < $input_file

    if [ $errore -ne 0 ]
    then
        case "$errore" in
            1) descrizione="risultato non conforme"
            ;;
            117) descrizione="eseguibile non trovato"
            ;;
            *)
        esac
        echo -e "$i: $u\t(almeno un) ERRORE: $descrizione"
    else
        echo -e "$i: $u\ttutto OK"
    fi
    i=$((i+1))
done < $githubusers