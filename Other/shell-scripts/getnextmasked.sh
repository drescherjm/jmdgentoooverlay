#!/bin/sh

run_emerge() 
{
if [ "$#" -gt "0" ]; then
	emerge -p $@ > $TMPFILE
else
	emerge -upDv system > $TMPFILE
fi
}

get_package_name()
{
	PACKAGENAME=`grep satisfy $TMPFILE | awk '{print $7}' | sed -e 's/"//g' -e 's/>//g' -e 's/=//g' -e 's/-[0123456789][^ ]*//'`
}

get_choices()
{
	grep $PACKAGENAME $TMPFILE | grep -v satisfy | grep -v package | sed 's/- //' | sort | uniq  > $TMPFILE1
}

PACKAGENAME=''
TMPFILE=`mktemp` 
TMPFILE1=`mktemp`
run_emerge $@

cat $TMPFILE

get_package_name

echo The necissary package is $PACKAGENAME

get_choices

cat $TMPFILE1

TESTVAL=`wc --lines $TMPFILE1 | awk '{print $1}'`

echo $TESTVAL

if `[ $TESTVAL -gt 0 ]`; then
echo "=`tail -1 $TMPFILE1 | awk '{print $1}'`" >> /etc/portage/package.keywords/local
sh $0 $@
fi
