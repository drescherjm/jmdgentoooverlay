#! /bin/bash

if [ -e $1 ]; then
TMPFILE=`mktemp /tmp/keywords.sorted.XXXXXXXXXX`
sort $1 | sed -e 's/[ \t]*$//' -e s/~amd64//g -e s/~x86//g | uniq  > ${TMPFILE}
cat ${TMPFILE} > $1
rm ${TMPFILE}

fi
