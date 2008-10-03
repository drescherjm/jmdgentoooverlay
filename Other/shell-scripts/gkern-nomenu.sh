#! /bin/bash
mount /boot
gunzip -c /proc/config.gz > /usr/src/linux/.config
cp /usr/src/linux/.config /usr/share/genkernel/x86_64/kernel-config-2.6
genkernel all --gensplash=livecd-2006.1 --save-config --color --install --gensplash-res=1024x768

#--bootloader=grub 
#--evms2
# --mountboot --no-bootsplash --gensplashopt=--res=1024x768
