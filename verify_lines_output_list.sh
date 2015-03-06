#!/bin/bash
# v0.1 - 06-mar-2015
#

cur_dir=`pwd`
repository_name=$1
input_file=$2
user_dir=$3
if [ -z $repository_name ] || [ -z $input_file ] || [ -z $user_dir ]
then
    echo 'ERROR: missing parameter'
    echo "$0 <repository_name> <input_file> <user_dir>"
    echo 'Returns the number of compliant outputs'
    exit 101
fi

##################################

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
output_patterns_file="${input_file}_outputpatterns"
#
user_dir_parent_path=`dirname $user_dir`
if [ "${user_dir_parent_path:0:1}" != '/' ]
then
	cd ${cur_dir}/${user_dir_parent_path}
	user_dir_parent_path=`pwd`
	user_dir=${user_dir_parent_path}/`basename $user_dir`
fi
#
user_list="${user_dir}/${repository_name}_cloned_miasoluzione_compiled"

##################################

# Check the existence of file and directories

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

if [ ! -f "${output_patterns_file}" ]
then
    echo "ERROR: unable to find the output patterns file ${output_patterns_file}"
    exit 105
fi

if [ ! -d $user_dir ]
then
    echo "ERROR: unable to find the user dir ${user_dir}"
    exit 106
fi

if [ ! -f $user_list ]
then
    echo "ERROR: unable to find the users' list ${user_list}"
    exit 107
fi

####

find_exe_path_script="${script_path}/find_exe_path.sh"
# The script necessarily exists here

user_n=0				# number of users
compliant_n=0			# number of compliant outputs
not_compliant_n=0		# number of not compliant outputs
partially_different=0	# number of partially different outputs
completely_different=0	# number of completely_different outputs (no single match)
while read user
do
	user_n=$((user_n+1))
	user_repository_path="${user_dir}/${user}/${repository_name}"
	if [ -d "${user_repository_path}" ] # Check the existence of the repository
	then	
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
				n_patterns=0
				n_matched_patterns=0
				while read pattern
				do
					n_patterns=$((n_patterns+1))
					grep -qi "$pattern" ${user_output}
					if [ $? -eq 0 ]; then
						n_matched_patterns=$((n_matched_patterns+1))
					fi
				done <${output_patterns_file}
				
				n_unmatched_patterns=$((n_patterns-n_matched_patterns))
				if [ ${n_unmatched_patterns} -eq 0 ]
				then
					echo "${user_n}: $user OK"
					compliant_n=$((compliant_n+1))
				else
					not_compliant_n=$((not_compliant_n+1))
					if [ ${n_unmatched_patterns} -eq ${n_patterns} ]; then
						echo "${user_n}: $user EMPTY (empty implementation?)"
						completely_different=$((completely_different+1))
					else
						echo "${user_n}: $user ERROR (${n_unmatched_patterns} unmatched patterns out of ${n_patterns})"
						partially_different=$((partially_different+1))
					fi					
				fi
			fi

			rm -f ${user_output}
			
		else
			echo "${user_n}: $user ERROR (unable to find EXE in ${repository_name})"
		fi
	else
		echo "${user_n}: $user ERROR (unable to find path ${user_repository_path})"
	fi
done < $user_list
echo "Total: ${user_n} - Compliant: ${compliant_n} - Not compliant: ${not_compliant_n} (${completely_different} completely different) - Other: $((user_n-compliant_n-not_compliant_n))"
exit ${compliant_n}