# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-plugins/mythvideo/mythvideo-0.21_pre14485.ebuild,v 1.1 2007/09/21 17:04:46 cardoe Exp $

inherit mythtv-plugins subversion

DESCRIPTION="Video player module for MythTV."
IUSE="mplayer xine"
KEYWORDS="~amd64 ~ppc ~x86"

RDEPEND="dev-perl/libwww-perl
	dev-perl/HTML-Parser
	dev-perl/URI
	dev-perl/XML-Simple
	mplayer? ( || ( media-video/mplayer media-video/mplayer-bin ) )
	xine? ( media-video/xine-ui )
	sys-apps/eject"
DEPEND="${RDEPEND}"

src_unpack() {
	subversion_src_unpack
	mythtv-plugins_src_unpack_patch
}

pkg_postinst() {
	elog "MythVideo can use any media player to playback files, since"
	elog "it's a setting in the setup menu."
	elog
	elog "MythTv also has an 'Internal' player you can use, though"
	elog "it will not support as many formats.  If you want to use it,"
	elog "set the player to 'Internal' (note spelling & caps)."
}
