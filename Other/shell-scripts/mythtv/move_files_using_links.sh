#!/bin/sh

###############################################################################

echo_red() {	
	echo -e "\033[1;31m$*\033[0m"
}

###############################################################################

processFile() {
	echo_red $1 $2
}


###############################################################################

export -f echo_red
export -f processFile

if [ "$#" -ne 2 ]; then
  echo_red "$0 <source_folder> <dest_folder>"
else
  find $1 -maxdepth 1 -mindepth 1 -type l -exec bash -c 'processFile "$1" "$0"' $2 {} \;
fi
