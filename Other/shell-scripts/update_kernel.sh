#! /bin/bash
mount /boot

if [ ! -f /usr/src/linux/.config ] ; then
	zcat /proc/config.gz > /usr/src/linux/.config
fi

local_version="$(date +%Y%m%d-%H%M)-$(uname -n)"

# Now add the date and machine name to the local version
sed -i '/CONFIG_LOCALVERSION/d' /usr/src/linux/.config
echo CONFIG_LOCALVERSION=\"-${local_version}\" >> /usr/src/linux/.config

if [ ! -e /etc/zfs/vdev_id.conf ]; then
  genkernel $@ all --kernel-append-localversion="-${local_version}" --save-config --color --install
  emerge @module-rebuild
else
  genkernel $@ all --save-config --kernel-append-localversion="-${local_version}" --color --install --zfs --bootloader=grub2 --callback="emerge --oneshot @module-rebuild sys-fs/zfs" 
fi
