#!/bin/sh

sh /root/shell-scripts/run_on_all_no_pass.sh /etc/init.d/ntp-client restart 2>&1 >> /var/log/ntp-update.txt &

eix-sync

emerge -eF world 2>&1 >> /var/log/update_distfiles.txt &

freshclam &

sh /root/shell-scripts/run_on_all_no_pass.sh emerge --sync

sh /root/shell-scripts/run_on_all_no_pass.sh rsync -ax --delete --progress rsync://192.168.2.83:/layman/  /var/lib/layman/

sh /root/shell-scripts/run_on_all_no_pass.sh rsync -ax --delete --progress rsync://192.168.2.83/gentoo-keywords/ /usr/local/gentoo-keywords/

sh run_on_all_no_pass.sh emerge -uDvNFp world >> /root/fetch.txt
sh run_on_all_no_pass.sh emerge -uDvNFp system >> /root/fetch.txt
sh run_on_all_no_pass.sh emerge -ep world >> /root/fetch.txt

sh /root/shell-scripts/run_on_all_no_pass.sh /root/shell-scripts/glsa-fix.sh

sh /root/shell-scripts/run_on_all_no_pass.sh rsync -ax --delete --progress rsync://192.168.2.83/clamav-db /var/lib/clamav
