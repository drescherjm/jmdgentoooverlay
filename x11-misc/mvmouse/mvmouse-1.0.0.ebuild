# Copyright 1999-2004 Gentoo Technologies, Inc.
# Distributed under the terms of the GNU General Public License v2
# $Header: $

# Ebuild by Zrajm C Akfohg <zrajm@klingonska.org> [2004-09-23]
DESCRIPTION="Shell command for moving X's mouse pointer"
HOMEPAGE="http://www.azundris.com/hacks/c/"
SRC_URI="http://www.azundris.com/hacks/c/${PN}.tar.bz2"
LICENSE="GPL-2"

SLOT="0"
KEYWORDS="~x86"
IUSE=""
DEPEND=""
RDEPEND="virtual/x11"
S="${WORKDIR}/${PN}"

src_compile() {
	emake || die "emake failed"
}

src_install() {
	dobin mvmouse
	dodoc AUTHORS COPYING* COPYING INSTALL README
}

