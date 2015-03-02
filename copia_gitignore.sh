fname='.gitignore'
if [ -e $fname ]
then
    for u in $(ls -d */)
    do
        for d in $(ls -d $u*/)
        do
            cp $fname $d
        done
    done
else
    echo "Impossibile trovare file $fname"
    exit 1
fi

