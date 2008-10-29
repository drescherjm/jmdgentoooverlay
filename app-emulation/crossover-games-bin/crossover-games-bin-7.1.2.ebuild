# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-emulation/crossover-games-pro-bin/crossover-games-pro-bin-6.2.0.ebuild,v 1.2 2007/12/27 21:30:54 vapier Exp $

inherit eutils

DESCRIPTION="simplified/streamlined version of wine with commercial support"
HOMEPAGE="http://www.codeweavers.com/products/cxgames/"
SRC_URI="install-crossover-games-${PV}.sh"

LICENSE="CROSSOVER"
SLOT="0"
KEYWORDS="-* amd64 x86"
IUSE="nas"
RESTRICT="fetch strip"

RDEPEND="sys-libs/glibc
	x11-libs/libXrandr
	x11-libs/libXi
	x11-libs/libXmu
	x11-libs/libXxf86dga
	x11-libs/libXxf86vm
	dev-util/desktop-file-utils
	nas? ( media-libs/nas )
	amd64? ( app-emulation/emul-linux-x86-xlibs )"

S=${WORKDIR}

pkg_nofetch() {
	einfo "Please visit ${HOMEPAGE}"
	einfo "and place ${A} in ${DISTDIR}"
}

src_unpack() {
	unpack_makeself
}

src_install() {
	dodir /opt/cxgames
	cp -r * "${D}"/opt/cxgames || die "cp failed"
	rm -r "${D}"/opt/cxgames/setup.{sh,data}
	insinto /opt/cxgames/etc
	doins share/crossover/data/cxgames.conf
}

pkg_postinst() {
	elog "Run /opt/cxgames/bin/cxsetup as normal user to create"
	elog "bottles and install Windows applications."
}
