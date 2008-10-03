#!/bin/bash
for foo in `find /var/db/pkg/ -mindepth 2 -type d | sed s:/var\/db\/pkg\/.*/::`;
do
[[ ! -f "/usr/portage/packages/All/${foo}.tbz2" ]] && time sudo quickpkg =${foo} ;
done
