# Copyright 2004-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils games

DESCRIPTION="Warcraft II for the Stratagus game engine (Needs WC2 DOS CD)"
HOMEPAGE="http://wargus.sf.net/"
SRC_URI="mirror://sourceforge/${PN}/${P}-src.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86"
IUSE=""

DEPEND="virtual/libc
	media-libs/libpng
	sys-libs/zlib"
RDEPEND="=games-engines/stratagus-2.1*"

pkg_setup() {
	cdrom_get_cds data/rezdat.war
	games_pkg_setup
}

src_install() {
	local dir="${GAMES_DATADIR}/stratagus/${PN}"
	dodir "${dir}"
	./build.sh -p "${CDROM_ROOT}" -o "${D}/${dir}" -v \
		|| die "Failed to extract data"
	games_make_wrapper wargus "./stratagus -d \"${dir}\"" "${GAMES_BINDIR}"
	prepgamesdirs
}

