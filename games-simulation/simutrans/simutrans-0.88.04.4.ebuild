# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/games-simulation/simutrans/simutrans-0.84.16.4.ebuild,v 1.2 2005/03/14 23:11:53 vapier Exp $

inherit games

DESCRIPTION="A free Transport Tycoon clone"
HOMEPAGE="http://www.simutrans.de/"
SRC_URI="http://64.simutrans.com/simulinux-88-04-4.zip
	http://64.simutrans.com/simupak64-88-04-3.zip
	http://64.simutrans.com/waste64-86-03.zip
	http://64.simutrans.com/food64-86-06.zip"

LICENSE="as-is"
SLOT="0"
KEYWORDS="-* ~amd64 ~x86"
IUSE=""

DEPEND="app-arch/unzip"
RDEPEND="media-libs/libsdl
	amd64? (
		app-emulation/emul-linux-x86-baselibs
		app-emulation/emul-linux-x86-xlibs
		app-emulation/emul-linux-x86-sdl
	)"

S=${WORKDIR}/${PN}

src_install() {
	local dir=${GAMES_PREFIX_OPT}/${PN}

	games_make_wrapper simutrans ./simutrans "${dir}"
	keepdir "${dir}/save"
	cp -R * "${D}/${dir}/" || die "cp failed"
	find "${D}/${dir}/"{text,font} -type f -print0 | xargs -0 chmod a-x
	prepgamesdirs
	fperms 2775 "${dir}/save"
}

