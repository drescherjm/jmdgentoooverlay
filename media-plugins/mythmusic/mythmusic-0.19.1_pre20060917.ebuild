# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-plugins/mythmusic/mythmusic-0.19.ebuild,v 1.2 2006/02/12 10:33:52 cardoe Exp $

inherit mythtv-plugins flag-o-matic toolchain-funcs eutils

DESCRIPTION="Music player module for MythTV."
HOMEPAGE="http://www.mythtv.org/"
SRC_URI="http://www.mythtv.org/mc/mythplugins-${PV}.tar.bz2"
RESTRICT="fetch"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~x86"

IUSE="aac fftw sdl"

RDEPEND=">=media-sound/cdparanoia-3.9.8
	>=media-libs/libmad-0.15.1b
	>=media-libs/libid3tag-0.15.1b
	>=media-libs/libvorbis-1.0
	>=media-libs/libcdaudio-0.99.6
	>=media-libs/flac-1.1.0
	aac? ( >=media-libs/faad2-2.0-r7 )
	fftw? ( =sci-libs/fftw-2* )
	sdl? ( >=media-libs/libsdl-1.2.5 )"

DEPEND="${RDEPEND}"

src_unpack() {
	if [[ $(gcc-version) = "3.2" || $(gcc-version) == "3.3" ]]; then
		replace-cpu-flags pentium4 pentium3
	fi

	mythtv-plugins_src_unpack || die "unpack failed"
}

MTVCONF="$(use_enable aac) $(use_enable fftw) $(use_enable sdl)"
