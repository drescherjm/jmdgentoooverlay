#!/bin/sh

ls -al /dev/disk/by-id | grep -v part | grep ata | awk 'BEGIN{a=0} { print "alias d"a" "$9; a+=1}'
