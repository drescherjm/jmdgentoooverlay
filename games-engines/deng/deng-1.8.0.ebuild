# Copyright 1999-2004 Gentoo Technologies, Inc.
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit games

MY_PV="${PV/_/-}"

DESCRIPTION="A modern gaming engine for Doom, Heretic and Hexen"
HOMEPAGE="http://www.doomsdayhq.com/"
SRC_URI="mirror://sourceforge/deng/${PN}-${MY_PV}.tar.gz"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86"
IUSE="openal"
DEPEND="virtual/opengl
		virtual/glu
		media-libs/libsdl
		media-libs/sdl-mixer
		media-libs/sdl-net
		openal? ( media-libs/openal )"

S=${WORKDIR}/${PN}-${MY_PV}

src_compile() {
	egamesconf || die "egamesconf failed"
	emake || die "emake failed"
}

src_install() {
	egamesinstall || die "egamesinstall failed"

	# startup scripts that make sure ~/.doomsday/$GAME exists
	cat << EOF > ${WORKDIR}/jdoom
#!/bin/sh
test -d ~/.doomsday/jdoom/ || mkdir -p ~/.doomsday/jdoom
cd ~/.doomsday/jdoom/
exec ${GAMES_BINDIR}/doomsday -game jdoom -file ${GAMES_DATADIR}/deng/Data/jDoom/doom.wad -userdir ~/.doomsday/jdoom "\$@"
EOF
	cat << EOF > ${WORKDIR}/jheretic
#!/bin/sh
test -d ~/.doomsday/jheretic/ || mkdir -p ~/.doomsday/jheretic
cd ~/.doomsday/jheretic/
exec ${GAMES_BINDIR}/doomsday -game jheretic -file ${GAMES_DATADIR}/deng/Data/jHeretic/heretic.wad -userdir ~/.doomsday/jheretic "\$@"
EOF
	cat << EOF > ${WORKDIR}/jhexen
#!/bin/sh
test -d ~/.doomsday/jhexen/ || mkdir -p ~/.doomsday/jhexen
cd ~/.doomsday/jhexen/
exec ${GAMES_BINDIR}/doomsday -game jhexen -file ${GAMES_DATADIR}/deng/Data/jHexen/hexen.wad -userdir ~/.doomsday/jhexen "\$@"
EOF

	dogamesbin ${WORKDIR}/{jdoom,jheretic,jhexen}
	dodoc ${S}/Doc/{ChangeLog,CVars,DEDDoc,Network}.txt
	dodoc ${S}/README
	prepgamesdirs
}

pkg_postinst() {
	games_pkg_postinst

	einfo "Each game(Doom/Heretic/Hexen) needs an IWAD file from"
	einfo "the original release in order to play."
	einfo ""
	einfo "E.g. for Hexen, you need to copy HEXEN.WAD to"
	einfo ""
	einfo "${GAMES_DATADIR}/deng/Data/jHexen/hexen.wad"
	einfo ""
	ewarn "The filename must be lower-case."
	echo
}

