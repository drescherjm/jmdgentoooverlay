#! /bin/bash
/etc/init.d/lircd stop
/etc/init.d/lircd zap
rm -Rf /dev/lirc
cd /usr/src/linux
patch -p1 -f < ~/files/lirc-2.6.4-20040318
cd ~/lirc-0.7.0pre7
./configure
make
make install
rm /dev/lirc
mkdir /dev/lirc
mknod /dev/lirc/0 c 61 0
/etc/init.d/lircd start
