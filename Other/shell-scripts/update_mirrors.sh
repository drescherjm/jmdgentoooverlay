#!/bin/sh

sed -i '/GENTOO_MIRRORS/d' /etc/portage/make.conf

echo "GENTOO_MIRRORS=\"http://gentoo.mirrors.pair.com/ ftp://gentoo.mirrors.pair.com/ http://mirror.mcs.anl.gov/pub/gentoo/ http://mirror.lug.udel.edu/pub/gentoo/ ftp://mirror.mcs.anl.gov/pub/gentoo/\"" >> /etc/portage/make.conf
