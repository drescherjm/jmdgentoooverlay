# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-apps/lkcdutils/lkcdutils-4.1.1.ebuild,v 1.5 2006/07/16 21:55:35 vapier Exp $

inherit eutils

MY_P=${P}
DESCRIPTION="Linux Kernel Crash Dumps (LKCD) Utilities"
HOMEPAGE="http://lkcd.sourceforge.net/ http://oss.software.ibm.com/developerworks/opensource/linux390/june2003_recommended.shtml"
SRC_URI="http://downloads.sourceforge.net/lkcd/lkcdutils-6.2.0.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="x86 amd64"
IUSE=""

DEPEND="app-arch/rpm2targz
	dev-util/byacc"

S=${WORKDIR}/${MY_P}


src_compile() {
	./configure \
		--prefix=/usr \
		--mandir=/usr/share/man \
		--infodir=/usr/share/info \
		--datadir=/usr/share \
		--sysconfdir=/etc \
		 --bfd_version=2.14.90 || die "configure failed"

	make || die "make failed"
}

src_install() {
	make install ROOT="${D}" || die "install failed"
	# not needed on s390
	rm -rf "${D}"/usr/share/sial \
		"${D}"/usr/lib/libsial.a \
		"${D}"/usr/include/sial_api.h \
		"${D}"/usr/include/lkcd/asm/lc_dis.h \
		"${D}"/etc \
		"${D}"/sbin/lkcd* \
		"${D}"/usr/man/man/lkcd*
	# broken configure script...
	mv -f "${D}"/usr/man "${D}"/usr/share/man
}
