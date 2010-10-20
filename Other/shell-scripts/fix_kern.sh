#!/bin/sh

echo "Removing deprecated SYSFS"
sed -i /usr/src/linux/.config -e 's/CONFIG_SYSFS_DEPRECATED=y/CONFIG_SYSFS_DEPRECATED is not set/g' -e 's/CONFIG_SYSFS_DEPRECATED_V2=y/CONFIG_SYSFS_DEPRECATED_V2 is not set/g'
