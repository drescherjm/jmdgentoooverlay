#!/bin/sh

sed -i '/GENTOO_MIRRORS/d' /etc/portage/make.conf

#echo "GENTOO_MIRRORS=\"http://gentoo.mirrors.pair.com/ ftp://gentoo.mirrors.pair.com/ http://mirror.mcs.anl.gov/pub/gentoo/ http://mirror.lug.udel.edu/pub/gentoo/ ftp://mirror.mcs.anl.gov/pub/gentoo/\"" >> /etc/portage/make.conf

#GENTOO_MIRRORS="http://gentoo.mirrors.pair.com/ ftp://gentoo.mirrors.pair.com/ http://gentoo.cites.uiuc.edu/pub/gentoo/ http://mirror.datapipe.net/gentoo"

GENTOO_MIRRORS="ftp://gentoo.mirrors.pair.com/ http://gentoo.mirrors.tds.net/gentoo ftp://mirror.leaseweb.com/$


