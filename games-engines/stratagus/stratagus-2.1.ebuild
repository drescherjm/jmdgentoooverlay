# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/games-engines/stratagus/stratagus-2.1.ebuild,v 1.10 2005/09/24 06:34:50 mr_bones_ Exp $

inherit games

MY_PV=040702
DESCRIPTION="A realtime strategy game engine"
HOMEPAGE="http://www.stratagus.org/"
SRC_URI="mirror://sourceforge/stratagus/${P}-src.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~x86"
IUSE="debug doc flac mp3 mikmod ogg opengl vorbis"

RDEPEND="virtual/x11
	app-arch/bzip2
	dev-lang/lua
	media-libs/libpng
	media-libs/libsdl
	sys-libs/zlib
	flac? ( media-libs/flac )
	mp3? ( media-libs/libmad )
	mikmod? ( media-libs/libmikmod )
	ogg? ( vorbis? ( media-libs/libogg media-libs/libvorbis ) )"
DEPEND="${RDEPEND}
	doc? ( app-doc/doxygen )"

S=${WORKDIR}/stratagus-${MY_PV}

src_compile() {
	local myconf

	if use ogg && use vorbis ; then
		myconf="--enable-ogg" \
	else
		myconf="--disable-ogg"
	fi
	econf \
		$(use_enable debug) \
		$(use_with mikmod) \
		$(use_with flac) \
		$(use_with mp3 mad) \
		$(use_with opengl) \
		${myconf} \
		|| die "econf failed"
	emake -j1 || die "emake failed"

	if use doc ; then
		emake doc || die "making source documentation failed"
	fi
}

src_install() {
	dogamesbin stratagus || die "dogamesbin failed"
	dodoc README
	dohtml -r doc/*
	use doc && dohtml -r srcdoc/html/*
	prepgamesdirs
}
