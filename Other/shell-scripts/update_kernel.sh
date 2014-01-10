#! /bin/bash
mount /boot

if [ ! -f /usr/src/linux/.config ] ; then
	zcat /proc/config.gz > /usr/src/linux/.config
fi

genkernel $@ all --save-config --color --install

emerge @module-rebuild
