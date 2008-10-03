#! /bin/bash

if [ -e $1 ]; then

sort $1 | sed -e 's/[ \t]*$//' -e s/~amd64//g -e s/~x86//g | uniq  > /tmp/keywords.sorted
cat /tmp/keywords.sorted > $1

fi
