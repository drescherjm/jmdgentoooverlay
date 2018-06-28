#!/bin/bash
#######################################################################
# This is a helper script that keeps snapraid parity info in sync with
# your data and optionally verifies the parity info. Here's how it works:
#   1) It first calls diff to figure out if the parity info is out of sync.
#   2) If parity info is out of sync, AND the number of deleted files exceed
#      X (configurable), it triggers an alert email and stops. (In case of
#      accidental deletions, you have the opportunity to recover them from
#      the existing parity info)
#   3) If partiy info is out of sync, AND the number of deleted files exceed X
#      AND it has reached/exceeded Y (configurable) number of warnings, force
#      a sync. (Useful when you get a false alarm above and you can't be bothered
#      to login and do a manual sync. Note the risk is if its not a false alarm
#      and you can't access the box before Y number of times the job is run  to
#      fix the issue... Well I hope you have other backups...)
#   4) If parity info is out of sync BUT the number of deleted files did NOT
#      exceed X, it calls sync to update the parity info.
#   5) If the parity info is in sync (either because nothing changed or after it
#      has successfully completed the sync job, it runs the scrub command to
#      validate the integrity of the data (both the files and the parity info).
#      Note that each run of the scrub command will validate only a (configurable)
#      portion of parity info to avoid having a long running job and affecting
#      the performance of the box.
#   6) Once all jobs are completed, it sends an email with the output to user
#      (if configured).
#
 
#
# CHANGELOG
# ---------
# 23/10/2011 Initial release
# 04/01/2015 Updated script to handle changes in SnapRAID v7.0
#            Added scrub job as an optional task (after diff and sync)
# 06/01/2015 Made the script more robust by adding checks to make sure preceding
#            jobs completed as expected before continuing with the subsequent jobs.
#            Made emailing output to user optional.
# 24/01/2015 Inserted a sed step to clean up crlf (aka dos/unix formatting issue)
#            in sync & scrub outputs.
#            Detect sync and scrub job failures and highlight to user via warning
#            subject line in email to user.
# 25/01/2015 Added option to reduce progress report output in email (default is 2 -
#            report only in 10% intervals).
# 26/01/2015 For terse = 2 setting, removed lines for 1-8% from output
# 05/02/2015 Added logic to perform forced sync after X number of warnings
#            Cleaned up formatting in script file (changed tabs to spaces)
#            Made consistent the use of [ in the test statements
# 08/02/2015 Added warning number to the email subject line so that it is easier to
#            tell how many warnings have been issued so far
# 04/03/2015 Corrected Scrub job status check (i.e. added check for text "Nothing
#            to do") to avoid sending false warning email
# 27/10/2015 Corrected Sync job status check (i.e. added check for text "Nothing to
#            do") to avoid sending false warning email
# 29/10/2015 Fixed a bug with the job status check not detecting the right strings
#
#######################################################################
# Expand PATH for smartctl
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
 
## USER DEFINED SETTINGS ##
# address where the output of the jobs will be emailed to.
# comment it out to disable email output
EMAIL_ADDRESS="drescherjm@gmail.com"
 
# Set the threshold of deleted files to stop the sync job from running.
# NOTE that depending on how active your filesystem is being used, a low
# number here may result in your parity info being out of sync often and/or
# you having to do lots of manual sync.
DEL_THRESHOLD=1
 
# Set number of warnings before we force a sync job.
# This option comes in handy when you cannot be bothered to manually
# start a sync job when DEL_THRESHOLD is breached due to false alarm.
# Set to 0 to ALWAYS force a sync (i.e. ignore the delete threshold above)
# Set to -1 to NEVER force a sync (i.e. need to manual sync if delete threshold is breached)
SYNC_WARN_THRESHOLD=-1
 
# Set percentage of array to scrub if it is in sync.
# i.e. 0 to disable and 100 to scrub the full array in one go
# WARNING - depending on size of your array, setting to 100 will take a very long time!
SCRUB_PERCENT=10
SCRUB_AGE=10
 
# Set the option to log SMART info. 1 to enable, any other values to disable
SMART_LOG=1
 
# this script will log its actions to a file at this location
LOG_FILE="/tmp/snapRAID.log"
# location of the snapraid binary
SNAPRAID_BIN="/usr/bin/snapraid"
# location of the mail program binary
MAIL_BIN="/usr/bin/mutt"
 
# how much progress output do we want to keep in email
# Default is 2 which means report progress in 10% intervals
# Set to 1 to report progress in 1% intervals
# Set to 0 to report everything
TERSE=2
 
## INTERNAL TEMP VARS ##
EMAIL_SUBJECT_PREFIX="[`hostname`] SnapRAID - "
TMP_OUTPUT="/tmp/snapRAID.out"
SYNC_WARN_FILE="/tmp/snapRAID.warnCount"
SYNC_WARN_COUNT=""
 
# auto determine names of content and parity files
CONTENT_FILE=`cat /etc/snapraid.conf | grep snapraid.content | head -n 1 | cut -d " " -f2`
PARITY_FILE=`cat /etc/snapraid.conf | grep snapraid.parity | head -n 1 | cut -d " " -f2`
 
# redirect all stdout to log file (leave stderr alone thou)
exec >> $LOG_FILE
 
# timestamp the job
echo "[`date`] SnapRAID Job started."
echo "SnapRAID DIFF Job started on `date`" > $TMP_OUTPUT
echo "----------------------------------------" >> $TMP_OUTPUT
 
#TODO - mount and unmount parity disk on demand!
 
#sanity check first to make sure we can access the content and parity files
if [ ! -e $CONTENT_FILE ]; then
  echo "[`date`] ERROR - Content file ($CONTENT_FILE) not found!"
  echo "ERROR - Content file ($CONTENT_FILE) not found!" >> $TMP_OUTPUT
  exit 1;
fi
 
if [ ! -e $PARITY_FILE ]; then
  echo "[`date`] ERROR - Parity file ($PARITY_FILE) not found!"
  echo "ERROR - Parity file ($PARITY_FILE) not found!" >> $TMP_OUTPUT
  exit 1;
fi
 
# run the snapraid DIFF command
echo "[`date`] Running DIFF Command."
$SNAPRAID_BIN diff >> $TMP_OUTPUT
# wait for the above cmd to finish
wait
 
echo "----------------------------------------" >> $TMP_OUTPUT
echo "SnapRAID DIFF Job finished on `date`" >> $TMP_OUTPUT
JOBS_DONE="DIFF"
 
DEL_COUNT=$(grep -w '^ \{1,\}[0-9]* removed$' $TMP_OUTPUT | sed 's/^ *//g' | cut -d ' ' -f1)
ADD_COUNT=$(grep -w '^ \{1,\}[0-9]* added$' $TMP_OUTPUT | sed 's/^ *//g' | cut -d ' ' -f1)
MOVE_COUNT=$(grep -w '^ \{1,\}[0-9]* moved$' $TMP_OUTPUT | sed 's/^ *//g' | cut -d ' ' -f1)
COPY_COUNT=$(grep -w '^ \{1,\}[0-9]* copied$' $TMP_OUTPUT | sed 's/^ *//g' | cut -d ' ' -f1)
UPDATE_COUNT=$(grep -w '^ \{1,\}[0-9]* updated$' $TMP_OUTPUT | sed 's/^ *//g' | cut -d ' ' -f1)
 
# sanity check to make sure that we were able to get our counts from the output of the DIFF job
if [ -z "$DEL_COUNT" -o -z "$ADD_COUNT" -o -z "$MOVE_COUNT" -o -z "$COPY_COUNT" -o -z "$UPDATE_COUNT" ]; then
  # failed to get one or more of the count values, lets report to user and exit with error code
  echo "[`date`] ERROR - failed to get one or more count values. Unable to proceed. Exiting script."
  if [ $EMAIL_ADDRESS ]; then
    $MAIL_BIN -s "$EMAIL_SUBJECT_PREFIX WARNING - Unable to proceed with SYNC/SCRUB job(s). Check DIFF job output inside." "$EMAIL_ADDRESS" < $TMP_OUTPUT
  fi
  exit 1;
fi
 
echo "SUMMARY of changes - Added [$ADD_COUNT] - Deleted [$DEL_COUNT] - Moved [$MOVE_COUNT] - Copied [$COPY_COUNT] - Updated [$UPDATE_COUNT]" >> $TMP_OUTPUT
 
# check if the conditions to run SYNC are met
# CHK 1 - if files have changed
if [ $DEL_COUNT -gt 0 -o $ADD_COUNT -gt 0 -o $MOVE_COUNT -gt 0 -o $COPY_COUNT -gt 0 -o $UPDATE_COUNT -gt 0 ]; then
  # CHK 1 - YES, files have changed
  # CHK 2 - if number of deleted files exceed DEL_THRESHOLD
  if [ $DEL_COUNT -lt $DEL_THRESHOLD ]; then
    # CHK 2 - NO, delete threshold not reached, lets run the sync job
    echo "Deleted files ($DEL_COUNT) did not exceed threshold ($DEL_THRESHOLD), proceeding with sync job." >> $TMP_OUTPUT
    echo "[`date`] Changes detected [A-$ADD_COUNT,D-$DEL_COUNT,M-$MOVE_COUNT,C-$COPY_COUNT,U-$UPDATE_COUNT] and deleted files ($DEL_COUNT) is below threshold ($DEL_THRESHOLD). Running SYNC Command."
    DO_SYNC=1
  else
    #CHK 2 - YES, delete threshold breached! print warning message to both outputs
    echo "Number of deleted files ($DEL_COUNT) exceeded threshold ($DEL_THRESHOLD)." >> $TMP_OUTPUT
    echo "[`date`] WARNING - Deleted files ($DEL_COUNT) exceeded threshold ($DEL_THRESHOLD). Check $TMP_OUTPUT for details."
    # CHK 3 - if forced sync is set
    if [ $SYNC_WARN_THRESHOLD -gt -1 ]; then
      # CHK 3 - YES
      echo "Forced sync is enabled." >> $TMP_OUTPUT
      echo "[`date`] Forced sync is enabled."
      # CHK 4 - if number of warnings has exceeded threshold
      SYNC_WARN_COUNT=$(sed 'q;/^[0-9][0-9]*$/!d' $SYNC_WARN_FILE 2>/dev/null)
      SYNC_WARN_COUNT=${SYNC_WARN_COUNT:-0} #value is zero if file does not exist or does not contain what we are expecting
      if [ $SYNC_WARN_COUNT -ge $SYNC_WARN_THRESHOLD ]; then
        # CHK 5 - YES, lets force a sync job. Do not need to remove warning marker here as it is automatically removed when the sync job is run by this script
        echo "Number of warning(s) ($SYNC_WARN_COUNT) has reached/exceeded threshold ($SYNC_WARN_THRESHOLD). Forcing a sync job to run." >> $TMP_OUTPUT
        echo "[`date`] Number of warning(s) ($SYNC_WARN_COUNT) has reached/exceeded threshold ($SYNC_WARN_THRESHOLD). Forcing a sync job to run."
        DO_SYNC=1
      else
        # CHK 4 - NO, so let's increment the warning count and skip the sync job
        ((SYNC_WARN_COUNT += 1))
        echo $SYNC_WARN_COUNT > $SYNC_WARN_FILE
        echo "$((SYNC_WARN_THRESHOLD - SYNC_WARN_COUNT)) warning(s) till forced sync. NOT proceeding with sync job." >> $TMP_OUTPUT
        echo "[`date`] $((SYNC_WARN_THRESHOLD - SYNC_WARN_COUNT)) warning(s) till forced sync. NOT proceeding with sync job."
        DO_SYNC=0
      fi
    else
      # CHK 3 - NO, so let's skip SYNC
      echo "Forced sync is not enabled. NOT proceeding with sync job. Please run sync manually if this is not an error condition." >> $TMP_OUTPUT
      echo "[`date`] Forced sync is not enabled. Check $TMP_OUTPUT for details. NOT proceeding with sync job."
      DO_SYNC=0
    fi
  fi
else
  # CHK 1 - NO, so let's skip SYNC
  echo "[`date`] No change detected. Not running SYNC job."
  DO_SYNC=0
fi
 
# Now run sync if conditions are met
if [ $DO_SYNC -eq 1 ]; then
  echo "SnapRAID SYNC Job started on `date`" >> $TMP_OUTPUT
  echo "----------------------------------------" >> $TMP_OUTPUT
  $SNAPRAID_BIN sync | sed -e 's/\r/\n/g' >> $TMP_OUTPUT
  #wait for the job to finish
  wait
  echo "----------------------------------------" >> $TMP_OUTPUT
  echo "SnapRAID SYNC Job finished on `date`" >> $TMP_OUTPUT
  JOBS_DONE="$JOBS_DONE + SYNC"
  # insert SYNC marker to 'Everything OK' or 'Nothing to do' string to differentiate it from SCRUB job later
  sed -i 's/^Everything OK/SYNC_JOB--Everything OK/g;s/^Nothing to do/SYNC_JOB--Nothing to do/g' $TMP_OUTPUT
  # Remove any warning flags if set previously. This is done in this step to take care of scenarios when user has manually synced or restored deleted files and we will have missed it in the checks above.
  if [ -e $SYNC_WARN_FILE ]; then
    rm $SYNC_WARN_FILE
  fi
  $SNAPRAID_BIN scrub -p new
fi
 
# Moving onto scrub now. Check if user has enabled scrub
if [ $SCRUB_PERCENT -gt 0 ]; then
  # YES, first let's check if delete threshold has been breached and we have not forced a sync.
  if [ $DEL_COUNT -gt $DEL_THRESHOLD -a $DO_SYNC -eq 0 ]; then
    # YES, parity is out of sync so let's not run scrub job
    echo "[`date`] Scrub job cancelled as parity info is out of sync (deleted files threshold has been breached)."
  else
    # NO, delete threshold has not been breached OR we forced a sync, but we have one last test -
    # let's make sure if sync ran, it completed successfully (by checking for our marker text "SYNC_JOB--" in the output).
    if [ $DO_SYNC -eq 1 -a -z "$(grep -w "SYNC_JOB-" $TMP_OUTPUT)" ]; then
      # Sync ran but did not complete successfully so lets not run scrub to be safe
      echo "[`date`] WARNING - check output of SYNC job. Could not detect marker <SYNC_JOB-->. Not proceeding with SCRUB job."
      echo "WARNING - check output of SYNC job. Could not detect marker <SYNC_JOB-->. Not proceeding with SCRUB job." >> $TMP_OUTPUT
    else
      # Everything ok - let's run the scrub job!
      echo "[`date`] Running SCRUB Command."
      echo "SnapRAID SCRUB Job started on `date`" >> $TMP_OUTPUT
      echo "----------------------------------------" >> $TMP_OUTPUT
      $SNAPRAID_BIN scrub -p $SCRUB_PERCENT -o $SCRUB_AGE | sed -e 's/\r/\n/g' >> $TMP_OUTPUT
      #wait for the job to finish
      wait
      echo "----------------------------------------" >> $TMP_OUTPUT
      echo "SnapRAID SCRUB Job finished on `date`" >> $TMP_OUTPUT
      JOBS_DONE="$JOBS_DONE + SCRUB"
      # insert SCRUB marker to 'Everything OK' or 'Nothing to do' string to differentiate it from SYNC job above
      sed -i 's/^Everything OK/SCRUB_JOB--Everything OK/g;s/^Nothing to do/SCRUB_JOB--Nothing to do/g' $TMP_OUTPUT
    fi
  fi
else
  echo "[`date`] Scrub job is not scheduled. Not running SCRUB job."
fi
 
# Moving onto logging SMART info if enabled
if [ $SMART_LOG -eq 1 ]; then
  $SNAPRAID_BIN smart >> $TMP_OUTPUT
  wait
fi
 
echo "Spinning down disks..." >> $TMP_OUTPUT
$SNAPRAID_BIN down
 
# all jobs done, let's send output to user if configured
if [ $EMAIL_ADDRESS ]; then
  echo "[`date`] Email address is set. Sending email report to <$EMAIL_ADDRESS>"
  # check if deleted count exceeded threshold
  if [ $DEL_COUNT -gt $DEL_THRESHOLD -a $DO_SYNC -eq 0 ]; then
    # YES, lets inform user with an appropriate subject line
    $MAIL_BIN -s "$EMAIL_SUBJECT_PREFIX WARNING $SYNC_WARN_COUNT - Number of deleted files ($DEL_COUNT) exceeded threshold ($DEL_THRESHOLD)" "$EMAIL_ADDRESS" < $TMP_OUTPUT
  elif [ -z "${JOBS_DONE##*"SYNC"*}" -a -z "$(grep -w "SYNC_JOB-" $TMP_OUTPUT)" ]; then
    # Sync ran but did not complete successfully so lets warn the user
    $MAIL_BIN -s "$EMAIL_SUBJECT_PREFIX WARNING - SYNC job ran but did not complete successfully" "$EMAIL_ADDRESS" < $TMP_OUTPUT
  elif [ -z "${JOBS_DONE##*"SCRUB"*}" -a -z "$(grep -w "SCRUB_JOB-" $TMP_OUTPUT)" ]; then
    # Scrub ran but did not complete successfully so lets warn the user
    $MAIL_BIN -s "$EMAIL_SUBJECT_PREFIX WARNING - SCRUB job ran but did not complete successfully" "$EMAIL_ADDRESS" < $TMP_OUTPUT
  else
    # OPTIONALLY, let's reduce the amount of status lines in output.
    if [ $TERSE -gt 1 ]; then
      # Report progress in interval of tens %
      sed -i '$!N; /^\([0-9]\).*\n\1.*$/!P; D'  $TMP_OUTPUT
      sed -i '/^[1-8]%.*$/d'  $TMP_OUTPUT
    elif [ $TERSE -gt 0 ]; then
      # Report progress in interval of ones %
      sed -i '$!N; /^\([0-9]*\)%.*\n\1.*$/!P; D'  $TMP_OUTPUT
    fi
    $MAIL_BIN -s "$EMAIL_SUBJECT_PREFIX INFO - $JOBS_DONE Jobs COMPLETED" "$EMAIL_ADDRESS" < $TMP_OUTPUT
  fi
fi
 
echo "[`date`] All jobs ended."
 
exit 0;
