#!/bin/bash
if [ -z "$1" ]; then
  echo -e "\nUsage: `basename $0` folder"
  exit 1
fi

if [ !  -d "$1" ]; then
  echo -e "Folder does not exist"
  exit 1
fi

for a in dev sys proc; do
  if [ ! -d "$1/$a" ]; then
     echo -e "Chroot missing $a"
     exit 1
  fi
done

cp /etc/resolv.conf "$1"/etc

mount --bind /dev "$1/dev"
mount -t proc none "$1/proc"
mount -t sysfs none "$1/sys"

mkdir -p "$1/usr/portage/distfiles"

mount --bind /usr/portage    "$1/usr/portage"
mount --bind /auto/distfiles "$1/usr/portage/distfiles"

chroot "$1" /bin/bash
