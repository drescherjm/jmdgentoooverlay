#! /bin/sh

initialize_vars() {
if [ ! "$1" ] ; then 
echo "USAGE: $0 <Filename>"
exit
fi

BASENAME=`echo $1 | sed -e 's#.*/##g' -e's/\..*//'`
TMPFOLDER="/tmp/mpeg/${BASENAME}"
#CUTLIST=`mythcommflag -f $1 --getskiplist | grep Commercial | sed -e 's/.*: //' -e 's/,/\n/'g`
CUTLIST=`mythcommflag -f $1 --getcutlist | grep list | sed -e 's/.*: //' -e 's/,/\n/'g`
}

create_tmp_folder() {
mkdir -p "${TMPFOLDER}"
if [ -d "${TMPFOLDER}" ] ; then
echo "Created folder ${TMPFOLDER}"
else
echo "ERROR: Could not create folder" ${TMPFOLDER}
exit
fi
}

generate_cut_list() {
if [ "${CUTLIST}" ] ; then
echo Using Cutlist ${CUTLIST}

else
echo "ERROR: Could not find a cutlist for "$1
exit
fi

echo "${CUTLIST}" > "${TMPFOLDER}"/cut.txt
echo "CollectionPanel.CutMode=2" > "${TMPFOLDER}"/cut2.txt
perl -w invert_cutlist.pl 9999999 "${TMPFOLDER}"/cut.txt | sed -e 's/-0 //' -e 's/-/\n/g' -e 's/ /\n/g' >> "${TMPFOLDER}"/cut2.txt
}

run_projectx() {
time projectx -demux -cut "${TMPFOLDER}"/cut2.txt -out "${TMPFOLDER}" -name "${BASENAME}" $1
}


remux() {
if [ ! -f "${TMPFOLDER}/${BASENAME}.m2v" ] ; then
echo "ERROR: ProjectX failed to create the video stream ${TMPFOLDER}/${BASENAME}.m2v"
exit
fi
time mplex -f8 -o "${TMPFOLDER}/${BASENAME}.mpg" "${TMPFOLDER}/${BASENAME}.m2v" "${TMPFOLDER}/${BASENAME}.mp2"
}

move_file(){
if [ -f "$1.old" ] ; then
echo "ERROR: $1.old exists."
exit
else
mv "$1" "$1.old"
fi
if [ -f "$1" ] ; then
echo "ERROR: $1 exists when it should have been moved to $1.old."
exit
else
mv "${TMPFOLDER}/${BASENAME}.mpg" "$1"
fi
}

update_database() {
FILESIZE=`du -b $1 | cut -f 1`
echo "update recorded set filesize=${FILESIZE} where basename='${BASENAME}.mpg';" | mysql -h jmd0 -u mythtv mythconverg
echo "update recorded set hostname='jmd1' where basename='${BASENAME}.mpg';" | mysql -h jmd0 -u mythtv mythconverg
mythcommflag -f $1 --clearcutlist
mythcommflag -f $1 --rebuild
}

initialize_vars $@

create_tmp_folder

generate_cut_list $@

run_projectx $@

remux

move_file $@

update_database $@


