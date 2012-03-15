#!/bin/sh

sed -i s'#CLEAN="yes"#CLEAN="no"#g' /etc/genkernel.conf 
sed -i s'#MRPROPER="yes"#MRPROPER="no"#g' /etc/genkernel.conf 
sed -i s'/# MAKEOPTS="-j2"/MAKEOPTS="-j10"/g' /etc/genkernel.conf 
sed -i s'/# LVM="no"/LVM="yes"/g' /etc/genkernel.conf 
sed -i s'/# MDADM="no"/MDADM="yes"/g' /etc/genkernel.conf 
sed -i s'/# BOOTLOADER="grub"/BOOTLOADER="grub"/g' /etc/genkernel.conf 
sed -i s'/# CLEAR_CACHE_DIR="yes"/CLEAR_CACHE_DIR="no"/g' /etc/genkernel.conf 
#sed -i s'-# KERNEL_CC="gcc"-KERNEL_CC="/usr/bin/icecc"-g' /etc/genkernel.conf 

