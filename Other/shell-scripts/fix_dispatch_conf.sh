#!/bin/sh

file=/etc/dispatch-conf.conf

sed -i -e s'#use-rcs=no#use-rcs=yes#g' -e s'#replace-wscomments=no#replace-wscomments=yes#g' \
-e s'#replace-unmodified=no#replace-unmodified=yes#g' \
-e s'#ignore-previously-merged=no#ignore-previously-merged=yes#g' \
-e s'/#log-file/log-file/g' \
-e s'@#frozen-files=""@frozen-files="/etc/bacula/bacula-dir.conf \
/etc/bacula/bacula-fd.conf \
/etc/bacula/bacula-sd.conf \
/etc/bacula/bconsole.conf \
/etc/bacula/bat.conf"@g' ${file} 

