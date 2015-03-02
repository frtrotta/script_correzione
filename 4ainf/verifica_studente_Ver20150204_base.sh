echo "v0.1 - 06-feb-2015"
studente=$1
stampa_output=$2
progetto="Ver20150204_base"
script_verifica="./verifica_$progetto.sh"
input_file="input_$progetto.txt"
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
    case $ret in
    0)
        echo "  Input $i OK"
        ;;
    18)
        echo "  Eseguibile non trovato"
        ;;
    17)
        echo "  ATTENZIONE: errata invocazione script"
        ;;
    *)
        echo "  Input $i Errore"
        ;;
    esac
    i=$((i+1))
done < $input_file