# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-themes/mythtv-themes/mythtv-themes-0.21_p16505.ebuild,v 1.7 2008/12/23 17:17:32 maekke Exp $

EAPI=1
inherit qt3 mythtv

DESCRIPTION="A collection of themes for the MythTV project."
SLOT="0"
KEYWORDS="amd64 ppc x86"
IUSE=""

DEPEND=">=x11-libs/qt-3.3:3
	=media-tv/mythtv-${MY_PV}*"

src_compile() {
	./configure --prefix=/usr || die "configure died"

	eqmake3 myththemes.pro -o "Makefile" || die "eqmake3 failed"
}

src_install() {
	einstall INSTALL_ROOT="${D}" || die "install failed"
}
