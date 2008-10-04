#!/bin/bash
#This script was written by John M. Drescher to bump mythtv to any svn revision.

#BEGIN Settings 

mythver=0.21_p
overlay_root=/usr/local/layman/jmd-gentoo
portage_root=/usr/portage

#END Settings

PREFIX=myth_upgrd
#package_versions=$(mktemp ${PREFIX}.XXXXXX)
package_versions=$(mktemp)

function get_package_list {
  packages=$(cat ${package_versions} |  sed -e 's/-0.21[^ ]*/\n/g' -e 's/ //g' | sort | uniq)
}

function update_repository {
#    svn add ${folder}/${new_version}.ebuild

   if [ -d $1/../.svn ]; then
      echo Updating repository for $1
      svn st $1 | grep ? | awk ' { print $2 }' | xargs -n1 -i svn add {}
      
   fi 
}

function unmask_package {
#TODO: I need to fix this for users who do not use package.keywords and package.unmask as folders

  echo =$1 >> /etc/portage/package.keywords/mythtv
  echo =$1 >> /etc/portage/package.unmask/mythtv
}

function bump_package {
    folder=${overlay_root}/$1
    mkdir -p ${folder}    

    if [ -d ${portage_root}/$1/files ]; then
       mkdir -p ${folder}/files 
       rsync ${portage_root}/$1/files/* ${folder}/files  
    fi 

    best_version=$(grep $1-${mythver} ${package_versions} | sort | tail -n1 | sed  -e 's/^[<>=]*[a-z0-9]*\-[a-z]*\///')
    new_version=$(echo ${best_version} | sed -e 's/\-[0-9].*$//')-${mythver}${svn_rvn}

if [ -f "${portage_root}/$1/${best_version}.ebuild" ];
then 
    cp ${portage_root}/$1/${best_version}.ebuild  ${folder}/${new_version}.ebuild
else
    cp ${folder}/${best_version}.ebuild ${folder}/${new_version}.ebuild
fi

    ebuild ${folder}/${new_version}.ebuild digest

    update_repository ${folder}

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
  echo "Usage: $0 <svn revision>"
elif [ "$1" -gt 15000 ]
then
  svn_rvn=$1
  equery list myth -p | grep ${mythver} | grep -v pre | sort | uniq > ${package_versions}
  get_package_list
  execute_main_loop
else
  echo "Please specify svn revision > 15000"
fi

