#!/bin/bash
# v0.1 - 06-mar-2015
#
# The output patterns file is assumed to have _output suffix with respect to the input file
# 0 SUCCESS

cur_dir=`pwd`
repository_name=$1
input_file=$2
user_dir=$3
user=$4
if [ -z $repository_name ] || [ -z $input_file ] || [ -z $user_dir ] || [ -z $user ]
then
    echo 'ERROR: missing parameter'
    echo "$0 <repository_name> <input_file> <user_dir> <user>"
    exit 101
fi

##################################

# Create absolute paths and names
if [ "${script_path:0:1}" != '/' ]
then
	script_path=`dirname $0`
	cd ${cur_dir}/${script_path}
	script_path=`pwd`
fi

input_path=`dirname $input_file`
if [ "${input_path:0:1}" != '/' ]
then
	cd ${cur_dir}/$input_path
	input_path=`pwd`
	input_file=${input_path}/`basename $input_file`
fi
output_patterns_file="${input_file}_output"
#
user_dir_parent_path=`dirname $user_dir`
if [ "${user_dir_parent_path:0:1}" != '/' ]
then
	cd ${cur_dir}/${user_dir_parent_path}
	user_dir_parent_path=`pwd`
	user_dir=${user_dir_parent_path}/`basename $user_dir`
fi
#
##################################

# Check the existence of file and directories
# if [ ! -d "$repository_path" ]
# then
    # echo "ERROR: unable to find repository $repository_path"
    # exit 102
# fi

if [ ! -d "$script_path" ]
then
    echo "ERROR: unable to find the path of the scripts $script_path"
    exit 103
fi

if [ ! -f "${input_file}" ]
then
    echo "ERROR: unable to find the input file $input_file"
    exit 104
fi

if [ ! -f "${output_patterns_file}" ]
then
    echo "ERROR: unable to find the output file ${output_file}"
    exit 105
fi


if [ ! -d "${user_dir}" ]
then
    echo "ERROR: unable to find the user dir $user_dir"
    exit 106
fi

####

find_exe_path_script="${script_path}/find_exe_path.sh"
# The script necessarily exists here

r=0
user_repository_path="${user_dir}/${user}/${repository}"
if [ -d ${user_repository_path} ] # Check the existence of the repository
then
		exe_path=`${find_exe_path_script} ${user_repository_path}`
		if [ -x "${exe_path}" ]
		then
			user_output=${user_repository_path}/`basename ${input_file}`_output
			${exe_path} <${input_file} >${user_output}
			all_patterns_matched=true
			while read pattern
			do
				pattern_matched=false
				while user_line
				do
					if [ ! -z `echo ${user_line} | grep "$pattern"` ]
					then
						pattern_matched=true
						break
					fi
				done <${user_output}
				if [ ! pattern_matched ]
				then
					echo "ERROR: ${pattern} not found"
					all_patterns_matched=false
				fi
			done <${output_patterns_file}
			
			if [ ! all_patterns_matched ]
			then
				r=1
				echo '=====> PATTERNS'
				cat ${output_patterns_file}
				echo '=====> USER OUTPUT'
				cat ${user_output}
			fi
			
			rm ${user_output}
		else
		    echo "${user_n}: ERROR: unable to find EXE in $repository for $user"
		    r=102
		fi
else
	echo "${user_n}: ERROR: unable to find path ${user_repository_path}"
	r=100
fi
exit $r