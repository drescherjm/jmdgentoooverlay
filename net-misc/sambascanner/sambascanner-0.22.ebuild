# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils toolchain-funcs

MY_P="SambaScanner-${PV}"
DESCRIPTION="a tool to search a whole samba network for files"
HOMEPAGE="http://www.johannes-bauer.com/sambascanner/"
SRC_URI="http://www.johannes-bauer.com/software/${PN}/${MY_P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE="debug linguas_de"

DEPEND=">=net-fs/samba-3"
RDEPEND="${DEPEND}"

S=${WORKDIR}/${MY_P}

src_compile() {
	econf $(use_enable debug) || die "econf failed"
	emake CC=$(tc-getCC) || die "emake failed"
}

src_install() {
	dobin src/sambascanner src/smblister bin/sambaretrieve
	dodoc ChangeLog AUTHORS
	if use linguas_de; then
		insinto /usr/share/locale/de/LC_MESSAGES
		doins i18n/sambascanner.mo
	fi
}

