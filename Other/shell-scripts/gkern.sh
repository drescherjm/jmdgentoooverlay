#! /bin/bash
mount /boot

if [ ! -f /usr/src/linux/.config ] ; then
	zcat /proc/config.gz > /usr/src/linux/.config
fi

cp /usr/src/linux/.config /usr/share/genkernel/x86_64/kernel-config-2.6
#genkernel $@ --menuconfig all --splash=livecd-2007.0 --save-config --color --install --splash-res=1024x768

genkernel $@ --menuconfig all --save-config --color --install

