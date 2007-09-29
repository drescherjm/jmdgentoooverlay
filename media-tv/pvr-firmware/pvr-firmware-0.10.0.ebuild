# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-tv/pvr-firmware/pvr-firmware-20061007.ebuild,v 1.5 2007/01/30 15:09:38 cardoe Exp $

inherit eutils


MY_P=ivtv-${PV}
S=${WORKDIR}

DESCRIPTION="firmware for Hauppauge PVR and Conexant based cards"
HOMEPAGE="http://www.ivtvdriver.org"
SRC_URI="http://dl.ivtvdriver.org/ivtv/firmware/firmware.tar.gz"

#Switched to recommended firmware by driver

RESTRICT="nomirror"
SLOT="0"
LICENSE="Conexant-firmware"
KEYWORDS="amd64 ppc x86"
IUSE=""

RDEPEND="|| ( >=sys-fs/udev-103 sys-apps/hotplug )
	 >=media-tv/ivtv-${PV}"

src_compile(){
	echo "Nothing to compile!"	
}

src_unpack()
{
      unpack ${A}
}

src_install() {
	dodir /lib/firmware
	insinto /lib/firmware
	doins *.fw
	doins *.mpg
}
