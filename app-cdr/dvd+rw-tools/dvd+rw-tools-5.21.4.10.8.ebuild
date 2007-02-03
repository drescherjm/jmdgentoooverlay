# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-cdr/dvd+rw-tools/dvd+rw-tools-5.21.4.10.8.ebuild,v 1.9 2005/04/20 08:20:58 corsair Exp $

inherit eutils

DESCRIPTION="A set of tools for DVD+RW/-RW drives"
HOMEPAGE="http://fy.chalmers.se/~appro/linux/DVD+RW/"
SRC_URI="http://fy.chalmers.se/~appro/linux/DVD+RW/tools/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="alpha amd64 hppa ia64 ppc ppc64 sparc x86"
IUSE=""

DEPEND="virtual/libc
	virtual/cdrtools"

src_unpack() {
	unpack ${A}
	cd ${S}
	epatch ${FILESDIR}/01_all_samsung-media-fix.patch
	epatch ${FILESDIR}/dvd+rw-tools-5.21.4.10.8.bacula.patch
}

src_compile() {
	sed -i \
		-e "s:^CFLAGS=\$(WARN).*:CFLAGS=${CFLAGS}:" \
		-e "s:^CXXFLAGS=\$(WARN).*:CXXFLAGS=${CXXFLAGS} -fno-exceptions:" \
		Makefile.m4 || die
	emake || die
}

src_install() {
	dobin dvd+rw-booktype dvd+rw-format dvd+rw-mediainfo growisofs || die
	dohtml index.html
	doman growisofs.1
}
