# Copyright 1999-2003 Gentoo Technologies, Inc.
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit kde-base || die
need-kde 3.2

DESCRIPTION="KDE Portage frontend"
HOMEPAGE="http://www.ralfhoelzer.com/kentoo.html"
SRC_URI="http://www.ece.cmu.edu/~rholzer/${P}.tar.bz2"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86"
IUSE=""
S=${WORKDIR}/${P}

pkg_nofetch() {
	einfo "Because of a wrongly hosted file which can't be downloaded"
	einfo "by wget, you have to do this manually and place it ${DISTDIR}"
    einfo "http://www.ece.cmu.edu/~rholzer/${P}.tar.bz2"
}

src_compile() {
	econf || die
	emake || die "emake failed"
}

src_install() {
	einstall || die 
}

