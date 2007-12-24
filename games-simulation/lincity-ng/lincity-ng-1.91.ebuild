# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/games-simulation/lincity-ng/lincity-ng-1.1.2.ebuild,v 1.2 2007/11/20 17:07:37 fmccor Exp $

inherit eutils games

MY_P=${P}.beta
S=${WORKDIR}/${MY_P}

DESCRIPTION="city/country simulation game for X and opengl"
HOMEPAGE="http://lincity-ng.berlios.de/"
SRC_URI="mirror://berlios/${PN}/${MY_P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~sparc ~x86"
IUSE=""

RDEPEND="virtual/opengl
	dev-libs/libxml2
	media-libs/libsdl
	media-libs/sdl-mixer
	media-libs/sdl-image
	media-libs/sdl-ttf
	media-libs/sdl-gfx
	dev-games/physfs"
DEPEND="${RDEPEND}
	dev-util/pkgconfig
	|| ( dev-util/ftjam dev-util/jam )"

pkg_setup() {
	games_pkg_setup
	if ! built_with_use media-libs/sdl-mixer vorbis ; then
		eerror "lincity-ng doesn't work properly if"
		eerror "sdl-mixer is built without vorbis support"
		die "Please emerge sdlmixer with USE=vorbis"
	fi
}

src_compile() {
	egamesconf || die
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
