#echo GENTOO_MIRRORS=\"ftp://gentoo.mirrors.pair.com/ http://gentoo.mirrors.tds.net/gentoo ftp://mirror.leaseweb.com/gentoo/ http://gentoo.osuosl.org/\" >> /etc/portage/make.conf
#!/bin/sh

sed -i '/GENTOO_MIRRORS/d' /etc/portage/make.conf

#echo GENTOO_MIRRORS=\"ftp://gentoo.mirrors.pair.com/ http://gentoo.mirrors.tds.net/gentoo ftp://mirror.leaseweb.com/gentoo/ http://gentoo.osuosl.org/\" >> /etc/portage/make.conf

#echo GENTOO_MIRRORS="http://gentoo.mirrors.pair.com/ http://mirror.leaseweb.com/gentoo/ http://mirrors.rit.edu/gentoo/ ftp://gentoo.mirrors.pair.com/" >> /etc/portage/make.conf
echo GENTOO_MIRRORS=\"http://mirror.leaseweb.com/gentoo/ http://gentoo.osuosl.org/ ftp://mirror.leaseweb.com/gentoo/ http://mirror.lug.udel.edu/pub/gentoo/\" >> /etc/portage/make.conf




