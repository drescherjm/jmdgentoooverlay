#!/bin/bash
source /etc/make.conf

for foo in `find /var/db/pkg/ -mindepth 2 -type d `;
do
#echo ${foo}
FullPkg=`echo ${foo} | sed s:/var\/db\/pkg\.::`
#echo ${FullPkg}
FileName=`echo ${foo} | sed s:/var\/db\/pkg\/.*/::`
#echo ${FileName} 
#| sed s:/var\/db\/pkg\/.*/::
[[ ! -f "$PKGDIR/All/${FileName}.tbz2" ]] && time sudo quickpkg --include-config=y =${FullPkg} ;
done
