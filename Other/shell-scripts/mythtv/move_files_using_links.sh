#!/bin/sh

###############################################################################

echo_red() {	
	echo -e "\033[1;31m$*\033[0m"
}

###############################################################################

processFile() {
	#echo_red $1 $2

	if [ -d "$1" ]; then

           if [ -L "$2" ]; then 
	      filename=$(readlink -f $2)
              if [ -f "${filename}" ]; then
                 #echo_red "${filename}"
                 rsync -ax --progress --remove-source-files "${filename}"* "$1"/
              else 
		echo_red "${filename} does not exist!"
              fi
           fi

        else
          echo_red "$1" is not a folder
        fi
}


###############################################################################

export -f echo_red
export -f processFile

if [ "$#" -ne 2 ]; then
  echo_red "$0 <source_folder> <dest_folder>"
else
  find $1 -maxdepth 1 -mindepth 1 -type l -exec bash -c 'processFile "$0" "$1"' $2 {} \;
fi
