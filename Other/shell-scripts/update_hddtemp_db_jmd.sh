#!/bin/bash

update_db() {
	local src=$1
	local dst=$2

	while read line ; do
		#if [[ -z $(echo "${line}" | sed -re 's/(^#.*|^\w*$)//') ]]; then
		#	echo "${line}" >> "${dst}"
		#fi

		id=$(echo "${line}" | grep -o '^"[^"]*"')
		echo "Looking for ${id}"
		grep "${id}" "${dst}" 2>&1 >/dev/null || (echo "Adding  ${id}" &&  echo "${line}" >> "${dst}")
	done < "${src}"
}

die() {
	echo "$*"
	exit 1
}

echo_red() {	
	echo -e "\033[1;31m$*\033[0m"
}



batch_dir_name="$( cd -P "$( dirname "$0" )" && pwd )"

update_data_file=${batch_dir_name}/data/hddtemp.jmd.db

if [ -e "${update_data_file}" ]; then

  cd /usr/share/hddtemp
  update_db "${update_data_file}" "hddtemp.db"

else
  echo_red "Update FAILED. Could not find update file!"
fi
