#!/bin/sh -e

# Copyright (C) 2010 John Pilkington 
# Largely based on scripts posted by Tino Keitel and Kees Cook in the Mythtv lists.

# Usage: ./mythcutprojectx <recording>
# <recording> is an mpeg2 file recorded by MythTV with a valid DB entry.

# This script is essentially a terminal-based replacement for the 'lossless' mpeg2 mythtranscode.
# It will pass the recording and the MythTV cutlist to ProjectX.
# If the cutlist is empty the entire recording will be processed.
# It uses ffmpeg to report what streams are present, chooses the first video and audio streams listed, 
# and gives the user TIMEOUT seconds to accept that choice or quit and make another.
# It uses ProjectX to demux, and mplex (from mjpegtools) to remux.
# Output format is DVD compliant without nav packets.
# It then clears the cutlist, updates the filesize in the database and rebuilds the seek table.
# The result is apparently acceptable as a recording within MythTV and as input to MythArchive.
# The ProjectX log file and ffmpeg stream analysis are kept. Other tempfiles are deleted.
# The variable INVERT controls the sense in which the cutlist is applied.

# The script needs to be edited to define some local variables.

####################

# Variables RECDIR1, RECDIR2, TEMPDIR1, TEMPDIR2, PROJECTX, PASSWD, INVERT need to be customised.
# At present (July 2010) MythTV trunk and fixes apparently apply the cutlist in opposite senses.
# TESTRUN is initially set to true so that the polarity of the cutlist that will be passed to Project-X can be checked
# RECDIR1 and TEMPDIR1 should if possible be on different drive spindles.  Likewise RECDIR2 and TEMPDIR2.

RECDIR1=/mnt/mythtv/jmd0_vg_2t3_0/videos
TEMPDIR1=/var/tmp/mythtv/tmp

RECDIR2=/mnt/mythtv/jmd0_vg_2t2_0/videos
TEMPDIR2=/var/tmp/mythtv/tmp

#PROJECTX=/path/to/ProjectX.jar (or to a link to it)
PROJECTX=$(equery files projectx | grep jar)

#PASSWD=`grep "^DBPassword" ~/.mythtv/mysql.txt | cut -d '=' -f 2-`
PASSWD=mythtv

# INVERT=true  # old MythTV setting, used in "fixes"
INVERT=false   # setting for use in trunk

TIMEOUT=20   # Longest 'thinking time' in seconds allowed before adopting the automatically selected audio stream.

#TESTRUN=true    # cutlists will be shown but the recording will be unchanged  
TESTRUN=false  # the recording will be processed
#################

if [ "$1" = "-h" ] || [ "$1" = "--help" ] ; then
echo "Usage: "$0" <recording>"
echo "<recording> is an mpeg2 file recorded by MythTV with a valid DB entry."
echo "e.g. 1234_20100405123400.mpg in one of the defined RECDIRs"
echo "The output file replaces the input file which is renamed to <recording>.old"
exit 0
fi

# exit if .old file exists

if  [ -f ${RECDIR1}/"$1".old ] ; then 
    echo " ${RECDIR1}/"$1".old exists: giving up." ; exit 1
fi

if  [ -f ${RECDIR2}/"$1".old ] ; then 
    echo " ${RECDIR2}/"$1".old exists: giving up." ; exit 1
fi
 
# Customize with paths to alternative recording and temp folders

cd $RECDIR1
TEMP=$TEMPDIR1
if  [ ! -f "$1" ] ; then
   cd $RECDIR2
   TEMP=$TEMPDIR2
     if  [ ! -f "$1" ] ; then 
       echo " "$1" not found.  Giving up"
       cd ~
       exit 1
     fi
fi 

if [ $# -lt 3 ]
then
   echo "Error: needs three arguments. Running  ffmpeg -i "$1" 2>&1 | grep -C 4 Video " 
   echo  
   ffmpeg -i "$1" 2>&1 | grep -C 4 Video | tee temp$$.txt
   echo

   # Thanks to Christopher Meredith for the basic parsing magic here. 
   VPID=`grep Video  temp$$.txt | head -n1 | cut -f 1,1 -d']' | sed 's+.*\[++g'`
   # It has to be tweaked for multiple audio streams.  This (with head -n1 ) selects the first listed by ffmpeg.
   # You may alternatively wish to select for language, format, etc.   May be channel, programme, user dependent.
   APID=`grep Audio  temp$$.txt | head -n1 | cut -f 1,1 -d']' | sed 's+.*\[++g'`

   echo -e "Choosing the first audio track listed by \" ffmpeg -i \".  It may not be the one you want."
   echo -e "\nThe selected values would be "$VPID" and "$APID".  The track info for these is \n"

   grep "$VPID" temp$$.txt
   grep "$APID" temp$$.txt

   echo -e "\nTo accept these values press \"a\", or wait....\n"  
   echo  "If you want to select other values, or quit to think about it, press another key within $TIMEOUT seconds."

   read -t $TIMEOUT -n 1 RESP
   if  [ $? -gt 128 ] ; then    
       RESP="a"
   fi

   if [ "$RESP" != "a" ] ; then
       echo -e "Quitting: if you want to select the PIDs from the command line its expected form is   \n"
       echo " "$0" 1234_20070927190000.mpg  0xvvv 0xaaa " 
       echo -e "                    filename_in_DB           vPID  aPID \n" 
       cd ~
       exit 1
   fi

   echo -e "Going on: processing with suggested values $VPID  $APID \n"
   grep "$VPID" temp$$.txt
   grep "$APID" temp$$.txt
   echo
else
   VPID="$2"
   APID="$3"
fi

#Now do the actual processing
# chanid and starttime identify the recording in the DB
chanid=`echo "select chanid from recorded where basename=\"$1\";" |
mysql -N -u mythtv  -p$PASSWD mythconverg `

starttime=`echo "select starttime from recorded where basename=\"$1\";" |
mysql -N -u mythtv  -p$PASSWD mythconverg `

# In 0.24 an initial zero is apparently treated as a normal cut-in point.
# list0 shows cut-in points and eof, but in 0.23 never includes zero
list0=`echo "select mark from recordedmarkup
where chanid=$chanid and starttime='$starttime' and type=0 order by mark;" |
mysql -N -u mythtv  -p$PASSWD mythconverg `
#list1 shows cut-out points.  In 0.23 an initial 0 here is a cut-in. 
list1=`echo "select mark from recordedmarkup
where chanid=$chanid and starttime='$starttime' and type=1 order by mark;" |
mysql -N -u mythtv  -p$PASSWD mythconverg `  

echo "CollectionPanel.CutMode=0" > cutlist$$ ;
if  ! $INVERT ; then 

    FIRSTCUT=`echo "select mark from recordedmarkup
    where chanid=$chanid and starttime='$starttime' and type=1 order by mark limit 1;" |
    mysql -N -u mythtv  -p$PASSWD mythconverg `  

    FIRSTEDIT=`echo "select mark from recordedmarkup
    where chanid=$chanid and starttime='$starttime' and type in (0,1) order by mark limit 1;" |
    mysql -N -u mythtv  -p$PASSWD mythconverg `  

    if [ ${FIRSTCUT} = ${FIRSTEDIT} ] ; then
        # echo "that was a cut-out point and we need to insert an earlier cut-in point"
        echo "0" >> cutlist$$
    fi

    list=`echo "select mark from recordedmarkup
    where chanid=$chanid and starttime='$starttime' and type in (0,1) order by mark;" |
    mysql -N -u mythtv  -p$PASSWD mythconverg ` 
 
else 
    for i in $list1 ;
      do
        if [ $i = "0" ] 
        then  
           list=`echo "select mark from recordedmarkup
              where chanid=$chanid and starttime='$starttime' and type in (0,1) order by mark;" |
              mysql -N -u mythtv  -p$PASSWD mythconverg | tail -n +2 ` 
              # tail -n +2 drops the initial zero.
        else
           echo "0" >> cutlist$$
           # That isn't quite the same as inserting a leading zero in list.  Does it matter?
           list=`echo "select mark from recordedmarkup
              where chanid=$chanid and starttime='$starttime' and type in (0,1) order by mark;" |
              mysql -N -u mythtv  -p$PASSWD mythconverg `  
       fi
     #  use only the first element of list1, as a switch.
       break
     done
fi 

# find the key frame (mark type 9) right before each cut mark,
# extract the byte offset, write it into the ProjectX cutlist
for i in $list ;
do echo "select offset from recordedseek
  where chanid=$chanid and starttime='$starttime' and type=9 and mark >= $i and mark < ($i + 100)
  order by offset;" |
  mysql -N -u mythtv  -p$PASSWD mythconverg | head -n 1
# for each cycle, head -n 1 yields the first line only.
done >> cutlist$$

echo "list0"
echo $list0
echo
echo "list1"
echo $list1
echo
echo "list"
echo $list
echo

echo -e "\"list\" is MythTV's frame-count cutlist that is used to create the byte-count cutlist used here by Project-X."
echo "At the time of writing (July 2010) the internal cutlists used by fixes and trunk appear to work in opposite senses."
echo "The cut can be inverted by adding or removing a leading zero. "
echo -e "That is what the INVERT variable does.  For fixes it should be set to \"true\" \n"

echo "This is the byte-count cutlist for Project-X. The first value is a cut-in point."
echo -e "Cut-out and cut-in then follow in sequence to EOF. \n"
cat cutlist$$
echo -e "\nThis is a test exit point for you to check that INVERT is correctly set."
echo -e "Its value now is  \"${INVERT}\".  When it's OK, edit the script to set TESTRUN=false.\n"

if $TESTRUN ; then
   rm -f cutlist$$
   rm -f temp$$.txt   
   cd ~
   exit 0
fi

mv  "$1" "$1".old

# use ProjectX to de-multiplex selected streams with the created cutlist
#ionice -c3 java -jar "$PROJECTX" -name tempcut$$ -id ${VPID},${APID} -out $TEMP -cut cutlist$$ "$1".old || :
ionice -c3 projectx -name tempcut$$ -id ${VPID},${APID} -out $TEMP -cut cutlist$$ "$1".old || :

# and pipe for re-multiplexing to mplex. -f 9 is dvd format without navpacks
DEMUXPREF=$TEMP/tempcut${$}
if [ -f $DEMUXPREF.mp2 ] ; then
    DEMUXAUDIO=$DEMUXPREF.mp2
else
    DEMUXAUDIO=$DEMUXPREF.ac3
fi
ionice -c3  mplex -o "$1" -V -f 9 $DEMUXPREF.m2v $DEMUXAUDIO
  
# tell mythDB about new filesize and clear myth cutlist
FILESIZE=`du -b "$1" | cut -f 1`
if [ "${FILESIZE}" -gt 1000000 ]; then
      echo "Running: update recorded set filesize=${FILESIZE} where basename=\"$1\";"
      echo "update recorded set filesize=${FILESIZE} where basename=\"$1\";" | mysql -u mythtv -p$PASSWD mythconverg
      echo "Filesize has been reset"
      echo "Running: ionice -c3 mythcommflag -f "$1" --clearcutlist"
      ionice -c3 mythcommflag -f "$1" --clearcutlist
      echo "Cutlist has been cleared"
fi

#rebuild seek table
echo "Running: ionice -c3 mythtranscode --mpeg2 --buildindex --showprogress --chanid "$chanid" --starttime "$starttime""
ionice -c3 mythtranscode --mpeg2 --buildindex --showprogress --chanid "$chanid" --starttime "$starttime"
echo -e "Seek table has been rebuilt.\n"

echo -e "Output file is $1.  INVERT is set to \"${INVERT}\".  PID streams $VPID and $APID were copied.\n"
if [ -f temp$$.txt ] ; then
     echo -e "Their original parameters were \n"
     grep "$VPID" temp$$.txt
     grep "$APID" temp$$.txt
     cat temp$$.txt >> "$DEMUXPREF"_log.txt
     echo
fi

rm -f "$1".png
#rm -f $TEMP/tempcut${$}*
mv  ${DEMUXPREF}_log.txt ${TEMP}/"$1"_pxlog.txt 
rm -f $DEMUXPREF.m2v
rm -f $DEMUXAUDIO
rm -f cutlist$$
rm -f temp$$.txt
cd ~
exit 0

