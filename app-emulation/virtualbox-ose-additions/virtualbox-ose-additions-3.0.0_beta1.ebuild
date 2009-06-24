# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-emulation/virtualbox-ose-additions/virtualbox-ose-additions-2.2.4.ebuild,v 1.1 2009/06/01 00:25:56 patrick Exp $

EAPI=2

inherit eutils

MY_PV=${PV/beta/BETA}
MY_PN=VBoxGuestAdditions
MY_P=${MY_PN}_${MY_PV}

DESCRIPTION="Guest additions for VirtualBox"
HOMEPAGE="http://www.virtualbox.org/"
SRC_URI="http://download.virtualbox.org/virtualbox/${MY_PV}/${MY_P}.iso"

LICENSE="PUEL"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND="!app-emulation/virtualbox-bin
	!=app-emulation/virtualbox-ose-9999"

src_unpack() {
	return 0
}

src_install() {
	insinto /usr/share/${PN/-additions}
	newins "${DISTDIR}"/${MY_P}.iso ${MY_PN}.iso
}
