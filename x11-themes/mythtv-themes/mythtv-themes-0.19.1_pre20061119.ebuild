# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-themes/mythtv-themes/mythtv-themes-0.19.ebuild,v 1.2 2006/05/23 04:55:45 cardoe Exp $

inherit qt3

DESCRIPTION="A collection of themes for the MythTV project."
HOMEPAGE="http://www.mythtv.org/"
SRC_URI="http://www.mythtv.org/mc/myththemes-${PV}.tar.bz2"
RESTRICT="fetch"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 ppc x86"
IUSE=""

RDEPEND="$(qt_min_version 3.3)
	>=media-tv/mythtv-${PV}"

S="${WORKDIR}/myththemes-${PV}"

src_compile() {
	cd ${S}
	./configure --prefix=/usr || die "configure died"

	${QTDIR}/bin/qmake QMAKE=${QTDIR}/bin/qmake -o "Makefile" myththemes.pro || die "qmake failed"
}

src_install() {
	einstall INSTALL_ROOT="${D}" || die "install failed"
}
