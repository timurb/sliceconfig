#!/bin/sh

sliceconfig=`dirname $0`/../..
sliceconfig=`readlink -f $sliceconfig`

variables=( $(cat "$sliceconfig/etc.conf" | sed 's,^[[:blank:]]*,,;s,[[:blank:]]*$,,' | egrep -v '^(#|$)') )

# various functions 
function copy_file()
{
    local x, src_file, dest_file
    src_file=$1
    dest_file=$2
    #check variables
    if [[ $# -lt 2  ]]; then
	echo "Usage: copy_file source_file destination_file"
	return 1;
    fi
    
    
    #check if file exists
    if [ -e "$dest_file" ]; then
	if [ -d "$dest_file" ]; then
	    # add filename to path
	    dest_file=$dest_file/"`basename $src_file`"
	else
	    #check for symlink
	    if [ -L "$dest_file" ]; then
		#symlink. unlink, move and delete it
		cp -L "$dest_file" "$dest_file.`date +%Y-%m-%d-%H:%M`"
		rm -f "$dest_file"
	    else
		#normal file
		mv -f "$dest_file" "$dest_file.`date +%Y-%m-%d-%H:%M`"
	    fi
	fi
    fi
    
    #create file
    cp -f "$src_file" "$dest_file"

    # replace variables
    for x in ${variables[@]}; do
	local variable,value
        variable=`echo $x|awk -F '=' '{print $1}'`
        value=`echo $x|awk -F '=' '{print $2}'`
        sed -i -e "s!$variable!$value!" $dest_file
    done
}

function get_value()
{
    key_name=$1
    for x in ${variables[@]};do
	variable=`echo $x|awk -F '=' '{print $1}'`
	value=`echo $x|awk -F '=' '{print $2}'`
	if [ $variable = $1 ];then
	    echo $value
	fi
    done
}
