# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/games-simulation/lincity-ng/lincity-ng-1.0.2.ebuild,v 1.3 2006/02/01 23:31:45 mr_bones_ Exp $

inherit eutils games

DESCRIPTION="city/country simulation game for X and opengl"
HOMEPAGE="http://lincity-ng.berlios.de/"
SRC_URI="http://download.berlios.de/lincity-ng/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 ~ppc x86"
IUSE=""

RDEPEND="
	virtual/opengl
	>=sys-libs/zlib-1.0.0
	>=dev-libs/libxml2-2.6.11
	>=media-libs/libsdl-1.2.5
	>=media-libs/sdl-mixer-1.2.4
	>=media-libs/sdl-image-1.2.3
	>=media-libs/sdl-ttf-2.0.0
	>=media-libs/sdl-gfx-2.0.13
	>=dev-games/physfs-1.0.0"

DEPEND="${RDEPEND}
	|| (
		( x11-libs/libXt x11-libs/libX11 x11-proto/xproto )
		virtual/x11
	)
	dev-util/pkgconfig
	>=dev-util/jam-2.5"

pkg_setup() {
	if ! built_with_use -o media-libs/sdl-mixer vorbis oggvorbis ; then
		eerror "lincity-ng doesn't work properly if"
		eerror "sdl-mixer is built without vorbis support"
		die "Please emerge sdlmixer with USE=vorbis"
	fi
	games_pkg_setup
}

src_compile() {
	egamesconf || die "configure failed"
	jam || die "jam failed"
}

src_install() {
	jam -sDESTDIR="${D}" \
		 -sappdocdir="/usr/share/doc/${PF}" \
		 -sapplicationsdir="/usr/share/applications" \
		 -spixmapsdir="/usr/share/pixmaps" \
		 install \
		 || die "jam install failed"
	prepalldocs
	prepgamesdirs
}
