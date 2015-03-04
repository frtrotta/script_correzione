#!/bin/bash
# v0.1 - 23-feb-2015
#

cur_dir=`pwd`
repository_path=$1
input_file=$2
user_dir=$3
user=$4
if [ -z $repository_path ] || [ -z $input_file ] || [ -z $user_dir ] || [ -z $user ]
then
    echo 'ERROR: missing parameter'
    echo "$0 <reference_repository_path> <input_file> <user_dir> <user>"
    exit 101
fi

##################################

# Create absolute paths and names
repository=`basename $repository_path`
repository_parent_path=`dirname $repository_path`
if [ "${repository_parent_path:0:1}" != '/' ]
then
	cd $repository_parent_path
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
##################################

# Check the existence of file and directories
if [ ! -d "$repository_path" ]
then
    echo "ERROR: unable to find repository $repository_path"
    exit 102
fi

if [ ! -d "$script_path" ]
then
    echo "ERROR: unable to find the path of the scripts $script_path"
    exit 103
fi

if [ ! -f "$input_file" ]
then
    echo "ERROR: unable to find the input file $input_file"
    exit 104
fi

if [ ! -d "$user_dir" ]
then
    echo "ERROR: unable to find the user dir $user_dir"
    exit 105
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

r=0
user_repository_path="${user_dir}/${user}/${repository}"
if [ -d ${user_repository_path} ] # Check the existence of the repository
then
#		cd ${user_repository_path}
#		make -f nbproject/Makefile-Debug.mk &>/dev/null
#		if [ $? -eq 0 ] # Compile the repository
#		then
		exe_path=`${find_exe_path_script} ${user_repository_path}`
		if [ -x "${exe_path}" ]
		then
			user_output=${user_repository_path}/`basename ${input_file}`_output
			${exe_path} <${input_file} >${user_output}
			diff -iZwBa ${reference_output} ${user_output}
			r=$?
			if [ $r -ne 0 ]
			then
				echo '===> USER'
				cat ${user_output}
				echo
				echo '===> REFERENCE'
				cat ${reference_output}
			fi
			rm ${user_output}
		else
		    echo "${user_n}: ERROR: unable to find EXE in $repository for $user"
		    r=102
		fi
#		else
#			echo "${user_n}: ERROR: unable compile $repository for $user"
#			r=101
#		fi
else
	echo "${user_n}: ERROR: unable to find path ${user_repository_path}"
	r=100
fi
rm $reference_output
exit $r