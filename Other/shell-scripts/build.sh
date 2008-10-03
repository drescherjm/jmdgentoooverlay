EMFLAGS="-uD --newuse"
LOGFOLDER="/tmp/build"
FAILEDPACKFILE=${LOGFOLDER}"/failed.txt"

on_success()
{
  rm $1 &> /dev/null
  rm $1.lastlog &> /dev/null
  rm $1.error.txt &> /dev/null
}

resume_build()
{
   # Resume until first success.

   echo $1 trying to resume build.
   
   emerge --resume --skipfirst 1>> $2 2>> $2
   while [ $? != 0 ]
   do
     echo resuming again on $1
     emerge --resume --skipfirst 1>> $2 2>> $2
   done

} 

on_failure()
{
   echo $1 failed
   echo $1 >> ${FAILEDPACKFILE}

   tail -n 30 $2 | grep '!!!' > $2.error.txt

   LASTBAD="`cat $2.error.txt | grep 'failed' | grep 'ERROR:' | awk '{print $3}'`"
   
   if [ "${LASTBAD}" != "" ] ; then
     if [ "${LASTBAD}" != "$1" ] ; then
        echo ${LASTBAD} is failed. 
        echo =${LASTBAD} >> ${FAILEDPACKFILE}
     fi
     else
       LASTBAD="`cat $2.error.txt | grep 'masked' | awk '{print $7}'`"

       if [ "${LASTBAD}" != "" ] ; then
          echo ${LASTBAD} is masked. 
          echo =${LASTBAD} >> ${FAILEDPACKFILE}        
       fi
   fi

   resume_build $1 $2   

   if [ `cat $2.error.txt | grep 'failed' | grep 'econf' | wc -l | awk '{print $1}'` -ge 1 ] ; then

     echo
     echo 'econf failed trying with FEATURES="-confcache"'
     echo

     FEATURES="-confcache" emerge ${EMFLAGS} $1 1>> $2 2>> $2
     if [ $? -eq 0 ]; then
        on_success ${FILENAME}
     fi 
   fi

}

build_package()
{
   FILENAME=${LOGFOLDER}/${1/\//.}.log

   if [ -f ${FILENAME} ] ; then 
      mv ${FILENAME} ${FILENAME}.lastlog
   fi

   emerge ${EMFLAGS} $1 &> ${FILENAME}

   if [ $? -eq 0 ]
   then
     on_success ${FILENAME}
   else
     on_failure $1 ${FILENAME}
   fi
}

mkdir -p ${LOGFOLDER}

WORK=`cat $1`

if [ -f ${FAILEDPACKFILE} ] ; then
   mv ${FAILEDPACKFILE} ${FAILEDPACKFILE}.old
fi

for a in ${WORK}
do
build_package $a
done

for ((b=1; b <= 3 ; b++))
do 
  if [ -f ${FAILEDPACKFILE} ] ; then
     echo
     echo "Restarting with failed packages" $b
     mv ${FAILEDPACKFILE} ${FAILEDPACKFILE}.lastrun
   
     for a in `cat ${FAILEDPACKFILE}.lastrun`
     do
       build_package $a
     done
  fi
done 

