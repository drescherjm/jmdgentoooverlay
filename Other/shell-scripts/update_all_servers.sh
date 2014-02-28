#!/bin/sh

sh /root/shell-scripts/run_on_all_no_pass.sh /etc/init.d/ntp-client restart 2>&1 >> /var/log/ntp-update.txt &

eix-sync

emerge -eF world 2>&1 >> /var/log/update_distfiles.txt &

sh /root/shell-scripts/run_on_all_no_pass.sh emerge --sync

sh /root/shell-scripts/run_on_all_no_pass.sh rsync -ax --delete --progress rsync://192.168.2.184:/layman  /usr/portage/local/layman

sh /root/shell-scripts/run_on_all_no_pass.sh rsync -ax --delete --progress rsync://192.168.2.184/gentoo-keywords/ /usr/local/gentoo-keywords/
