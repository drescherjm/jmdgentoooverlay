# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils games

DESCRIPTION="a Warcraft like RTS game"
HOMEPAGE="http://dark-oberon.sourceforge.net/"
SRC_URI="mirror://sourceforge/${PN}/${P}.tgz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="x86"
IUSE=""

DEPEND="virtual/opengl
	virtual/glu
	>=media-libs/glfw-2.5
	media-libs/fmod"

src_unpack() {
	unpack ${A}
	cd "${S}"
	rm -rf libs
	cd src
	epatch "${FILESDIR}"/${PV}-makefile.patch
}

src_compile() {
	emake SOUND=1 CPPFLAGS="${CXXFLAGS}" -C src || die "emake failed"
}

src_install() {
	dogamesbin doberon || die "dogamesbin failed"
	insinto "${GAMES_DATADIR}/${PN}"
	doins -r dat maps nets races schemes || die "doins failed"
	insinto /usr/share/doc/${PF}/pdf
	doins docs/*.pdf
	prepgamesdirs
}
