#!/bin/sh

sed -i '/GENTOO_MIRRORS/d' /etc/make.conf

echo "GENTOO_MIRRORS=\"http://chi-10g-1-mirror.fastsoft.net/pub/linux/gentoo/gentoo-distfiles/ http://mirror.mcs.anl.gov/pub/gentoo/ http://mirrors.rit.edu/gentoo/ ftp://chi-10g-1-mirror.fastsoft.net/pub/linux/gentoo/gentoo-distfiles/\"" >> /etc/make.conf
