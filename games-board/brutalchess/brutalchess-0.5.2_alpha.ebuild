# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils autotools games

if [[ "${PV:0-6}" = "_alpha" ]] ; then
	MY_PV=${PV/_alpha}
	MY_PV=alpha-${MY_PV}
else
	MY_PV=${PV}
fi

MY_P=${PN}-${MY_PV}

DESCRIPTION="OpenGL chess game"
HOMEPAGE="http://brutalchess.sourceforge.net/"
SRC_URI="mirror://sourceforge/${PN}/${MY_P}-src.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE=""

DEPEND=">=media-libs/freetype-2.1.9
	virtual/glut
	>=media-libs/libsdl-1.2.7
	media-libs/sdl-image
	x11-libs/libICE
	x11-libs/libSM
	x11-libs/libX11
	x11-libs/libXext
	x11-libs/libXi
	x11-libs/libXmu
	x11-libs/libXt"

S=${WORKDIR}/${MY_P/-alpha}

src_compile() {
	eautoreconf

	egamesconf \
		docdir="/usr/share/doc/${PF}" \
		|| die "egamesconf failed"

	emake || die "emake failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"

	# Image is too large, but better than nothing
	newicon art/${PN}logo.png ${PN}.png || die "newicon failed"
	make_desktop_entry ${PN} "Brutal Chess" ${PN}.png

	# Compress the docs, and remove COPYING & INSTALL
	rm -rf "${D}/usr/share/doc"
	dodoc AUTHORS ChangeLog NEWS README

	prepgamesdirs
}
