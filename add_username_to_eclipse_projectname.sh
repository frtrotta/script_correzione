echo "v0.1 - 31-mag-2015"
repository=$1
githubusers=$2
if [ -z "${repository}" ] || [ -z "${githubusers}" ]
then
	echo "ERROR: missing parameter(s)" >/dev/stderr
	echo "$0 <repository> <githubusers_file_list>" >/dev/stderr
	exit 1
fi

while read u
do
	sed -i "s/<name>${repository}/<name>${repository}_${u}/" "${u}/${repository}/.project"
	if [ $? -eq 0 ]
	then
		echo "${u}/${repository}/.project"
	else
		echo "Exiting because of error" >/dev/stderr
		exit 2
	fi
done < ${githubusers}
