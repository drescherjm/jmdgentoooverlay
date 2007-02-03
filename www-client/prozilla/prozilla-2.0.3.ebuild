# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/www-client/prozilla/prozilla-1.3.7.3.ebuild,v 1.5 2005/02/10 12:10:52 taviso Exp $

inherit eutils

DESCRIPTION="A download manager"
HOMEPAGE="http://prozilla.genesys.ro/"
SRC_URI="http://prozilla.genesys.ro/downloads/prozilla/tarballs/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="x86 sparc ~ppc amd64"
IUSE=""

RDEPEND="virtual/libc
	>=sys-libs/ncurses-5.2"
DEPEND="${RDEPEND}
	>=sys-apps/sed-4"

src_unpack() {
	unpack ${A}
	cd ${S}
#	epatch ${FILESDIR}/${P}-gentoo.diff
#	epatch ${FILESDIR}/${PN}-expands-format-twice.diff
}

src_install () {
	make DESTDIR="${D}" install || die "make install failed"
#	dodoc ANNOUNCE AUTHORS CREDITS ChangeLog FAQ NEWS README TODO
#	newdoc prozrc.sample prozilla.conf.example
}
