# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-plugins/mythgame/mythgame-0.21_pre14242.ebuild,v 1.1 2007/08/21 16:18:04 cardoe Exp $

inherit mythtv-plugins subversion

DESCRIPTION="Game emulator module for MythTV."
IUSE=""
KEYWORDS="~amd64 ~ppc ~x86"

RDEPEND="sys-libs/zlib"
DEPEND="${RDEPEND}"

src_install () {
	mythtv-plugins_src_install || die "install failed"

	dodoc gamelist.xml
}
