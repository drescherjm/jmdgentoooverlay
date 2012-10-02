#!/bin/sh

sed -i '/distfiles/d' /etc/autofs/auto.auto

echo "distfiles       -fstype=nfs,nfsvers=3,rw,timeo=100,tcp,soft,intr                                        datastore2:/auto/btrfs_data/distfiles" >> /etc/autofs/auto.auto

umount /auto/distfiles -fl
/etc/init.d/autofs reload

sed -i '/DISTDIR/d' /etc/make.conf
echo "DISTDIR=\"/auto/distfiles/x86\"" >> /etc/make.conf
