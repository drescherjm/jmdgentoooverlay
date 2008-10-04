#!/bin/bash

mythver=0.21_p
#overlay_root=/usr/local/portage/gentoo-overlay
#overlay_root=/usr/local/JMDGentooOverlay/gentoo-overlay
overlay_root=/usr/local/layman/jmd-gentoo

PREFIX=myth_upgrd
#package_versions=$(mktemp ${PREFIX}.XXXXXX)
package_versions=$(mktemp)


function get_package_list {
  packages=$(cat ${package_versions} |  sed -e 's/-0.21[^ ]*/\n/g' -e 's/ //g' | sort | uniq)
}

function unmask_package {
  echo =$1 >> /etc/portage/package.keywords/mythtv
  echo =$1 >> /etc/portage/package.unmask/mythtv
}

function bump_package {
    folder=${overlay_root}/$1
    mkdir -p ${folder}
    best_version=$(grep $1-${mythver} ${package_versions} | sort | tail -n1 | sed  -e 's/^[<>=]*[a-z0-9]*\-[a-z]*\///')
    new_version=$(echo ${best_version} | sed -e 's/\-[0-9].*$//')-${mythver}${svn_rvn}

if [ -f "/usr/portage/$1/${best_version}.ebuild" ];
then 
    cp /usr/portage/$1/${best_version}.ebuild  ${folder}/${new_version}.ebuild
else
    cp ${folder}/${best_version}.ebuild ${folder}/${new_version}.ebuild
fi
    ebuild ${folder}/${new_version}.ebuild digest

    svn add ${folder}/${new_version}.ebuild

    unmask_package $1-${mythver}${svn_rvn}
}

function execute_main_loop {
  for a in ${packages} ; 
  do
    bump_package $a
  done
}

if [ -z "$1" ]  
then 
  echo "Please specify svn revision"
elif [ "$1" -gt 15000 ]
then
  svn_rvn=$1
  equery list myth -p | grep ${mythver} | grep -v pre | sort | uniq > ${package_versions}
  get_package_list
  execute_main_loop
else
  echo "Please specify svn revision > 15000"
fi

