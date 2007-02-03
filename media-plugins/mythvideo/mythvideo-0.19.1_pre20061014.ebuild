# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-plugins/mythvideo/mythvideo-0.19.ebuild,v 1.4 2006/06/06 03:36:50 halcy0n Exp $

inherit eutils mythtv-plugins

DESCRIPTION="Video player module for MythTV."
HOMEPAGE="http://www.mythtv.org/"
SRC_URI="http://www.mythtv.org/mc/mythplugins-${PV}.tar.bz2"
IUSE=""
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ppc ~x86"

RDEPEND="dev-perl/libwww-perl
	dev-perl/HTML-Parser
	dev-perl/URI
	dev-perl/XML-Simple
	media-video/mplayer"
DEPEND="${RDEPEND}"

src_unpack() {
	mythtv-plugins_src_unpack
#	epatch "${FILESDIR}"/${P}-gcc41.patch
}
