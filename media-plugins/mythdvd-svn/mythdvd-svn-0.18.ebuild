# Copyright 1999-2005 Gentoo Foundation
# Copyright 2005 Preston Crow
#  ( If you make changes, please add a copyright notice above, but
#    never remove an existing notice. )
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit myth-svn

DESCRIPTION="DVD player module for MythTV."
HOMEPAGE="http://www.mythtv.org/"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="transcode vcd"

RDEPEND=">=media-plugins/mythvideo-svn-${PV}*
	media-libs/libdvdread
	virtual/mythtvlibs
	!media-plugins/mythdvd
	!media-plugins/mythdvd-cvs"

DEPEND=">=sys-apps/sed-4
	${RDEPEND}"

RDEPEND="${RDEPEND}
	 transcode? ( media-video/transcode )
	 || ( media-video/mplayer media-video/xine-ui media-video/ogle )"

setup_pro() {
	myconf="${myconf} $(use_enable vcd) $(use_enable transcode)"
	return 0
}
