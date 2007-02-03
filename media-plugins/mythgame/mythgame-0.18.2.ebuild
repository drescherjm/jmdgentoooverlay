# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-plugins/mythgame/mythgame-0.18.1.ebuild,v 1.4 2005/07/27 11:33:13 pvdabeel Exp $

inherit mythtv-plugins

DESCRIPTION="Game emulator module for MythTV."
HOMEPAGE="http://www.mythtv.org/"
SRC_URI="http://www.mythtv.org/mc/mythplugins-${PV}.tar.bz2"
IUSE=""
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ppc ~x86"

DEPEND=" sys-libs/zlib
	~media-tv/mythtv-${PV}"

src_install () {
	mythtv-plugins_src_install || die "install failed"

	dodoc gamelist.xml
}
