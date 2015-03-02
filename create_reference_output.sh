#!/bin/bash
# v0.3 - 23-feb-2015
#
# Crea un file di testo contenente l'output di riferimento da utilizzare nella
# verifica di programmi C.
# 
# Il percorso del repository è considerato conentere, come ultimo elemento, il nome del
# repository.
#
cur_dir=`pwd`
repository_path=$1	# requested
input_file=$2		# requested
output_file=$3		# requested
compile=$4			# not requested
if [ -z $repository_path ] || [ -z $input_file ] || [ -z $output_file ]
then
    echo 'ERROR: missing parameter'
    echo "Usage: $0 <repository_path> <input_file> <output_file> <compile>"
    echo
    echo 'Example'
    echo "$0 ../Ver20150220_01 ./input_Ver20150220_02.txt ./output_Ver20150220_02.txt 0"
    echo
    echo 'When compile is present and set to 0, the reference program is _not_ debug compiled'
    echo
    exit 1
fi

if [ ! -d $repository_path ]
then
    echo "ERROR: unable to find $repository_path"
    exit 2
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
script_path=`dirname $0`
if [ "${script_path:0:1}" != '/' ]
then
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
output_path=`dirname $output_file`
if [ "${output_path:0:1}" != '/' ]
then
	cd ${cur_dir}/$output_path
	output_path=`pwd`
	output_file=${output_path}/`basename $output_file`
fi
#
##################################

#echo $repository_parent_path
#echo $script_path
#echo $input_file
#echo $output_file
#exit

# Check the existence of file and directories
if [ ! -d $repository_path ]
then
    echo "ERROR: unable to find $repository_path"
    exit 2
fi

if [ ! -d $script_path ]
then
    echo "ERROR: unable to find $script_path"
    exit 3
fi

if [ ! -f $input_file ]
then
    echo "ERROR: unable to find $input_file"
    exit 4
fi

####

# Program debug compilation
if [ $compile -eq 0 ]
then
	cd ${repository_parent_path}/${repository}
	make -f nbproject/Makefile-Debug.mk &>/dev/null
	if [ $? -ne 0 ]
	then
	    echo "ERROR: unable compile $repository"
	    exit 10
	fi
fi
##################################

# Find executable name
find_exe_path_script="${script_path}/find_exe_path.sh"
if [ ! -x $find_exe_path_script ]
then
    echo "ERROR: unable to find $find_exe_path_script"
    exit 11
fi
#$find_exe_path_script ${repository_path}
exe_path=`${find_exe_path_script} ${repository_path}`

if [ -z ${exe_path} ]
then
    echo "ERROR: unable to find the reference executable in ${repository_parent_path}/$repository"
    exit 12
fi
##################################

# Create reference output
$exe_path <$input_file >$output_file
#$exe_path <$input_file
echo $output_file
##################################