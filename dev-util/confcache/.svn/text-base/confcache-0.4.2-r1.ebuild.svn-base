# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-util/confcache/confcache-0.4.2-r1.ebuild,v 1.3 2006/05/20 11:17:41 flameeyes Exp $

inherit distutils

DESCRIPTION="global autoconf cache manager"
HOMEPAGE="http://gentooexperimental.org/~ferringb/confcache/"
SRC_URI="http://dev.gentooexperimental.org/~masterdriverz/${P}.tar.bz2"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~hppa ~ppc ~sparc ~x86"
IUSE=""
DEPEND=">=dev-lang/python-2.2"
RDEPEND=">=dev-lang/python-2.2 >=sys-apps/sandbox-1.2.12"

src_install() {
	distutils_src_install
	rm -rf "${D}/usr/share/doc/confcache"

	fperms 0755 /usr/share/confcache
}

pkg_postinst() {
	ewarn "If you are upgrading from an older version of confcache please check"
	ewarn "the permissions on /usr/share/confcache directory. If the directory"
	ewarn "is world-writable, issue the following command to fix them:"
	einfo "  chmod 0755 /usr/share/confcache"
}
