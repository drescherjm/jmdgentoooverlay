# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-plugins/mythgame/mythgame-0.19.ebuild,v 1.3 2006/06/06 03:35:57 halcy0n Exp $

inherit eutils mythtv-plugins

DESCRIPTION="Game emulator module for MythTV."
HOMEPAGE="http://www.mythtv.org/"
SRC_URI="http://www.mythtv.org/mc/mythplugins-${PV}.tar.bz2"
IUSE=""
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~x86"

RDEPEND="sys-libs/zlib"
DEPEND="${RDEPEND}"

src_unpack() {
	mythtv-plugins_src_unpack
}

src_install () {
	mythtv-plugins_src_install || die "install failed"

	dodoc gamelist.xml
}
