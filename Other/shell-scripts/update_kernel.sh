#! /bin/bash
mount /boot

if [ ! -f /usr/src/linux/.config ] ; then
	zcat /proc/config.gz > /usr/src/linux/.config
fi

if [ ! -e /etc/zfs/vdev_id.conf ]; then
  genkernel $@ all --save-config --color --install
  emerge @module-rebuild
else
  genkernel $@ all --save-config --color --install --zfs --bootloader=grub2 --callback="emerge --oneshot @module-rebuild sys-fs/zfs" 
fi
