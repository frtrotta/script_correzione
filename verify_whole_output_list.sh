#!/bin/bash
# v1.0 - 04-mar-2015
#

cur_dir=`pwd`
repository_path=$1
input_file=$2
user_dir=$3
if [ -z $repository_path ] || [ -z $input_file ] || [ -z $user_dir ]
then
    echo 'ERROR: missing parameter'
    echo "$0 <reference_repository_path> <input_file> <user_dir>"
    echo 'Returns the number of compliant outputs'
    exit 101
fi

##################################

# Create absolute paths and names
repository=`basename $repository_path`
repository_parent_path=`dirname $repository_path`
if [ "${repository_parent_path:0:1}" != '/' ]
then
	cd "$repository_parent_path"
	repository_parent_path=`pwd`
	repository_path=${repository_parent_path}/${repository}
fi
#
if [ "${script_path:0:1}" != '/' ]
then
	script_path=`dirname $0`
	cd ${cur_dir}/${script_path}
	script_path=`pwd`
fi
#
input_path=`dirname $input_file`
if [ "${input_path:0:1}" != '/' ]
then
	cd ${cur_dir}/$input_path
	input_path=`pwd`
	input_file=${input_path}/`basename $input_file`
fi
#
user_dir_parent_path=`dirname $user_dir`
if [ "${user_dir_parent_path:0:1}" != '/' ]
then
	cd ${cur_dir}/${user_dir_parent_path}
	user_dir_parent_path=`pwd`
	user_dir=${user_dir_parent_path}/`basename $user_dir`
fi
#
user_list="${user_dir}/${repository}_cloned_miasoluzione_compiled"
# user_list_path=`dirname $user_list`
# if [ "${user_list_path:0:1}" != '/' ]
# then
	# cd ${cur_dir}/${user_list_path}
	# user_list_path=`pwd`
	# user_list=${user_list_path}/`basename $user_list`
# fi
#
##################################

# Check the existence of file and directories
if [ ! -d $repository_path ]
then
    echo "ERROR: unable to find repository $repository_path"
    exit 102
fi

if [ ! -d $script_path ]
then
    echo "ERROR: unable to find the path of the scripts $script_path"
    exit 103
fi

if [ ! -f $input_file ]
then
    echo "ERROR: unable to find the input file $input_file"
    exit 104
fi

if [ ! -d $user_dir ]
then
    echo "ERROR: unable to find the user dir $user_dir"
    exit 105
fi

if [ ! -f $user_list ]
then
    echo "ERROR: unable to find the users' list $user_list"
    exit 106
fi

####

# Create reference output
reference_output=${input_file}_referenceoutput
${script_path}/create_reference_output.sh ${repository_path} ${input_file} ${reference_output} 1 &>/dev/null
##################################



#echo $reference_output
#echo $repository_path
#echo $script_path
#echo $input_file
#echo $user_dir
#echo $user_list
#exit

find_exe_path_script="${script_path}/find_exe_path.sh"
# The script necessarily exists here

user_n=0			# number of users
compliant_n=0		# number of compliant outputs
not_compliant_n=0	# number of not compliant outputs
while read user
do
	user_n=$((user_n+1))
	user_repository_path="${user_dir}/${user}/${repository}"
	if [ -d "${user_repository_path}" ] # Check the existence of the repository
	then
#		cd ${user_repository_path}
#		make -f nbproject/Makefile-Debug.mk &>/dev/null
#		if [ $? -eq 0 ] # Compile the repository
#		then

	
			exe_path=`${find_exe_path_script} ${user_repository_path}`
			if [ -x "${exe_path}" ]
			then
				user_output=${user_repository_path}/`basename ${input_file}`_output
				${exe_path} <${input_file} >${user_output} &
				pid=$!
				timeout=7
				while [ $timeout -gt 0 ]
				do
					if [ -z "`ps -s | grep $pid`" ]
					then
						break
					fi
					sleep 1
					timeout=$(($timeout - 1))
				done
				if [ $timeout -eq 0 ]
				then
					kill $pid
					echo "${user_n}: $user ERROR (process killed)"
					
				else
					diff -iZwBa ${reference_output} ${user_output} &>/dev/null
					if [ $? -eq 0 ]
					then
						echo "${user_n}: $user OK"
						compliant_n=$((compliant_n+1))
					else
						echo "${user_n}: $user ERROR (different output)"
						not_compliant_n=$((not_compliant_n+1))
					fi
				fi

				rm -f ${user_output}
				
			else
			    echo "${user_n}: $user ERROR (unable to find EXE in $repository)"
			fi
#		else
#			echo "${user_n}: ERROR: unable compile $repository for $user"
#		fi
	else
		echo "${user_n}: $user ERROR (unable to find path ${user_repository_path})"
	fi
done < $user_list
rm ${reference_output}
echo "Total: ${user_n} - Compliant: ${compliant_n} - Not compliant: ${not_compliant_n} - Other: $((user_n-compliant_n-not_compliant_n))"
exit ${compliant_n}