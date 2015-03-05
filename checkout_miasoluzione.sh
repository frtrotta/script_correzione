echo "v1.1 - 05-mar-2015"
repository=$1
tokenfile=$3
if [ -z $repository ]
then
	echo "ERROR: missing parameter"
	echo "$0 <repository>"
	exit 1
fi

githubusers="${repository}_cloned"

temp='output.txt'
curdir=`pwd`
errorreport="$curdir/${githubusers}_miasoluzione.err"
echo "Errorreport file is $errorreport (if created)"
rm $errorreport &> /dev/null

newusers="${githubusers}_miasoluzione"
rm $newusers &> /dev/null

declare -a possible_branches=( 'miasoluzione' 'miaSoluzione' 'Miasoluzione' 'MiaSoluzione' )

n=0
s=0
while read u;
do
	n=$((n+1))
	cd $u/$repository/
	if [ $? -eq 0 ]
	then
                branch=""
                for b in ${possible_branches[@]}
                do
                    git branch --all | grep "remotes/origin/$b" &> /dev/null
                    if [ $? -eq 0 ]
                    then
                        branch="$b"
                        break
                    fi
                done

                if [ -z "$branch" ]
                then
                    echo "$n: $u ERROR could not find miasoluzione (and similar) branch"
                    echo "$u could not find miasoluzione (and similar) branch" >> "$errorreport"
                else
                    git checkout $branch &> "$temp"
                    if [ $? -eq 0 ]
                    then
                            s=$((s+1))
                            echo "==> $n: $u OK $branch checked out"
                            echo "$u" >> "$curdir/$newusers"
                    else
                            echo "$n: $u ERROR failed checking out $branch"
                            echo "$u ERROR failed checking out $branch" >> "$errorreport"
                    fi
                fi
                   
		cd ../..
	else
		echo "$n: $u ERROR: unable to find directory"
		echo "$u unable to find directory" >> "$errorreport"
	fi
done < $githubusers
echo "$n users read - $s repositories successfully checked out (miasoluzione)"
echo -e "\nUpdated users' list in $newusers"
