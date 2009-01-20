#!/bin/bash

function update {
  [ ! -e $1 ] && mkdir -p $1
  if [ ! -d $1 ]; then 
     mv $1 $1.old
     mkdir -p $1
     mv $1.old $1/local
  fi
}

update /etc/portage/package.keywords 
update /etc/portage/package.mask
update /etc/portage/package.unmask 




