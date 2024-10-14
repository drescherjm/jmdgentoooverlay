#! /bin/bash
mount /boot

if [ ! -f /usr/src/linux/.config ] ; then
	zcat /proc/config.gz > /usr/src/linux/.config
        zcat /proc/config.gz > /usr/share/genkernel/arch/x86_64/generated-config
fi

# Now add the date and machine name to the local version
sed -i '/CONFIG_LOCALVERSION/d' /usr/src/linux/.config
echo CONFIG_LOCALVERSION=\"-$(date +%Y%m%d-%H%M)-$(uname -n)\" >> /usr/src/linux/.config

if [ ! -e /etc/zfs/vdev_id.conf ]; then
  genkernel $@ all --save-config --color --install
  emerge @module-rebuild
else
  genkernel $@ all --save-config --color --install --zfs --bootloader=grub2 --callback="emerge --oneshot @module-rebuild sys-fs/zfs" 
fi
