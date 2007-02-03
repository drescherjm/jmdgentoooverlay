# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-plugins/mythbrowser/mythbrowser-0.19.ebuild,v 1.3 2006/02/14 00:28:14 cardoe Exp $

inherit mythtv-plugins kde-functions multilib eutils

DESCRIPTION="Web browser module for MythTV."
HOMEPAGE="http://www.mythtv.org/"
SRC_URI="http://www.mythtv.org/mc/mythplugins-${PV}.tar.bz2"
IUSE=""
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~x86"
RESTRICT="fetch"

RDEPEND=">=kde-base/kdelibs-3.1"
DEPEND="${RDEPEND}"

src_unpack() {
	mythtv-plugins_src_unpack

	epatch "${FILESDIR}"/mythbrowser-kde-3.5.patch

	set-kdedir
	echo "INCLUDEPATH += ${KDEDIR}/include" >> settings.pro
	echo "EXTRA_LIBS += -L${KDEDIR}/$(get_libdir)" >> settings.pro
}
