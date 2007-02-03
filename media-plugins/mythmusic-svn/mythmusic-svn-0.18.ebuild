# Copyright 1999-2005 Gentoo Foundation
# Copyright 2005 Preston Crow
#  ( If you make changes, please add a copyright notice above, but
#    never remove an existing notice. )
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit myth-svn

DESCRIPTION="Music player module for MythTV."
HOMEPAGE="http://www.mythtv.org/"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="opengl sdl X aac"

DEPEND=">=media-sound/cdparanoia-3.9.8
	>=media-libs/libmad-0.15.1b
	>=media-libs/libid3tag-0.15.1b
	>=media-libs/libvorbis-1.0
	>=media-libs/libcdaudio-0.99.6
	>=media-libs/flac-1.1.0
	>=sys-apps/sed-4
	aac? ( >=media-libs/faad2-2.0-r4 )
	X? ( =sci-libs/fftw-2* )
	opengl? ( virtual/opengl =sci-libs/fftw-2* )
	sdl? ( >=media-libs/libsdl-1.2.5 )
	virtual/mythtvlibs
	!media-plugins/mythmusic
	!media-plugins/mythmusic-cvs"

setup_pro() {
	myconf="${myconf}
		$(use_enable aac)
		$(use_enable X fftw)
		$(use_enable opengl)
		$(use_enable sdl)
	"
	return 0
}
