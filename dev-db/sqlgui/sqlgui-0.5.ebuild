# Copyright 1999-2004 Gentoo Technologies, Inc.
# Distributed under the terms of the GNU General Public License v2
# $Header: /home/cvsroot/gentoo-x86/dev-db/sqlgui/sqlgui-0.5.ebuild,v 1.3 2004/03/14 17:22:44 mr_bones_ Exp $

inherit kde

need-kde 3

newdepend ">=dev-db/mysql-3.23.38
	>=dev-db/sqlguipart-${PV}"

MY_P="${PN}-${PV}.0"
DESCRIPTION="GUI for the dev-db/sqlguipart, administration tool for a mysql db"
SRC_URI="http://www.sqlgui.de/download/${MY_P}.tar.gz"
HOMEPAGE="http://www.sqlgui.de/"

SLOT="0"
LICENSE="GPL-2"
KEYWORDS="~x86"
S=${WORKDIR}/${MY_P}

myconf="$myconf --with-extra-includes=/usr/include/mysql"


src_unpack() {

	cd ${WORKDIR}
	unpack ${A}
	cd ${S}
#	epatch ${FILESDIR}/${P}-gcc3.diff
}
