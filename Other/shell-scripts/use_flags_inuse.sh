#!/bin/sh

# Use this if you want to check installed packages
#EQUERY_CMD="equery -q hasuse"
# Use this if you want to check the full portage and overlay trees
EQUERY_CMD="equery -q hasuse -p -o"

which equery >/dev/null 2>&1
if [ $? -eq 1 ] ; then
    echo "Error: equery is required."
    exit 1
fi

source /etc/make.conf

echo "Searching for unused USE flags..."

for flag in $USE; do
    tmp_flag="`echo $flag | sed -e 's/^-//'`"
    COUNT="`$EQUERY_CMD $tmp_flag | wc -l`"
    if [ "$COUNT" -eq 0 ] ; then
        echo "  $flag is unused"
    fi
done
