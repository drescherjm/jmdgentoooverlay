#!/bin/sh

tempfile=$(mktemp)

if [ -z "${tempfile}" ]; then
  echo "FATAL_ERROR: Could not create a temp file. Exiting."
  exit;
fi

cat /root/fetch.txt | sort | uniq | sed '/\(^http\|^ftp\).*/!d;s/\ .*$//g' | sort | uniq > ${tempfile}

DISTDIR=/usr/portage/distfiles

if [ -e /etc/make.conf]; then
  source /etc/make.conf
else
  if [ -e /etc/portage/make.conf ]; then
    source /etc/portage/make.conf
  fi
fi

if [ -z "${DISTDIR}" ]; then
  echo "FATAL_ERROR: For some reason the DISTDIR is empty."
  exit;
fi

if [ ! -e "${DISTDIR}" ]; then
  echo "FATAL_ERROR: For some reason the DISTDIR does not exist."
  exit;
fi

cd ${DISTDIR}

wget --timeout=2 -t 2 -c -i ${tempfile}

if [ -e ${tempfile} ]; then
  rm ${tempfile}
fi

