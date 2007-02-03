# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-cdr/dvd+rw-tools/dvd+rw-tools-6.1.ebuild,v 1.1 2006/01/29 23:47:12 metalgod Exp $

inherit eutils

DESCRIPTION="A set of tools for DVD+RW/-RW drives"
HOMEPAGE="http://fy.chalmers.se/~appro/linux/DVD+RW/"
SRC_URI="http://fy.chalmers.se/~appro/linux/DVD+RW/tools/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~hppa ~ia64 ~ppc ~ppc64 ~sparc ~x86"
IUSE=""

DEPEND="virtual/libc
	virtual/cdrtools"

src_unpack() {
        unpack ${A}
        cd ${S}
        epatch ${FILESDIR}/dvd+rw-tools-6.1.bacula.patch
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

pkg_postinst() {
	einfo
	einfo "When you run growisofs if you receive:"
	einfo "unable to anonymously mmap 33554432: Resource temporarily unavailable"
	einfo "error message please run 'ulimit -l unlimited'"
}
