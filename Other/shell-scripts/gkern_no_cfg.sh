#! /bin/bash
mount /boot
gunzip -c /proc/config.gz > /usr/src/linux/.config
echo "CONFIG_FB_SPLASH=y" >> /usr/share/genkernel/x86/kernel-config-2.6
genkernel all --gensplash=emergence --save-config --color --install --gensplash-res=1024x768

#--bootloader=grub 
#--evms2
# --mountboot --no-bootsplash --gensplashopt=--res=1024x768
