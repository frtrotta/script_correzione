#!/bin/bash

base_dir=$1

if [ -z "${base_dir}" ]
then
	echo 'ERROR: missing parameter' >/dev/stderr
	echo "$0 <base_dir>" >/dev/stderr
	exit 1
fi

user_dir_list=$(find ${base_dir} -type d -mindepth 1 -maxdepth 1)

for user_dir in ${user_dir_list}
do
	user_name=$(basename ${user_dir})
	subdir_list=$(find ${user_dir} -type d -mindepth 1 -maxdepth 1)
	for subdir in ${subdir_list}
	do
		echo ${subdir} | grep -e _${user_name}$ &>/dev/null
		if [ $? -eq 0 ]
		then
			mv "${subdir}" "${subdir/_${user_name}/}"
			if [ $? -eq 0 ]
			then
				echo "${subdir} => ${subdir/_${user_name}/}"
			else
				echo 'Exiting because of error in renaming' >/dev/stderr
				exit 2
			fi
		fi
	done
done
