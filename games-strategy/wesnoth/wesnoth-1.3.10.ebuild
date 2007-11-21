# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/games-strategy/wesnoth/wesnoth-1.2.7.ebuild,v 1.6 2007/10/22 04:13:35 kingtaco Exp $

inherit eutils toolchain-funcs flag-o-matic games

MY_PV=${PV/_/}
DESCRIPTION="Battle for Wesnoth - A fantasy turn-based strategy game"
HOMEPAGE="http://www.wesnoth.org/"
SRC_URI="mirror://sourceforge/wesnoth/${PN}-${MY_PV}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 ppc ppc64 sparc x86 ~x86-fbsd"
IUSE="dedicated editor gnome kde lite nls server tools"

RDEPEND=">=media-libs/libsdl-1.2.7
	!dedicated? (
		x11-libs/libX11
		>=media-libs/freetype-2 )
	>=media-libs/sdl-mixer-1.2
	>=media-libs/sdl-image-1.2
	media-libs/sdl-net
	nls? ( virtual/libintl )"
# the configure script is broken and checks for freetype even if
# it won't be used.  until it's either patched out or upstream fixes
# it, just make it a DEPEND.
# reported by Miika Linnapuomi
DEPEND="${RDEPEND}
	dedicated? ( >=media-libs/freetype-2 )
	nls? ( sys-devel/gettext )"

S=${WORKDIR}/${PN}-${MY_PV}

pkg_setup() {
	if ! built_with_use media-libs/sdl-mixer vorbis ; then
		die "Please emerge media-libs/sdl-mixer with USE=vorbis"
	fi
	if ! built_with_use media-libs/sdl-image png ; then
		die "Please emerge media-libs/sdl-image with USE=png"
	fi
	if ! use dedicated && ! built_with_use media-libs/libsdl X ; then
		die "Please emerge media-libs/libsdl with USE=X"
	fi
	games_pkg_setup
}

src_unpack() {
	unpack "${A}"
	if use server ; then
		sed \
			-e "s:GAMES_BINDIR:${GAMES_BINDIR}:" \
			-e "s:GAMES_STATEDIR:${GAMES_STATEDIR}:" \
			-e "s/GAMES_USER_DED/${GAMES_USER_DED}/" \
			-e "s/GAMES_GROUP/${GAMES_GROUP}/" "${FILESDIR}"/wesnothd.rc \
			> "${T}"/wesnothd \
			|| die "sed failed"
	fi
}

src_compile() {
	filter-flags -ftracer -fomit-frame-pointer
	if [[ $(gcc-major-version) -eq 3 ]] ; then
		filter-flags -fstack-protector
		append-flags -fno-stack-protector
	fi
	egamesconf \
		--disable-dependency-tracking \
		--without-fribidi \
		--with-localedir=/usr/share/locale \
		--with-icondir=/usr/share/icons \
		--with-desktopdir=/usr/share/applications \
		$(use_enable lite) \
		$(use_enable server) \
		$(use_enable server campaign-server) \
		$(use server && echo --with-server-uid=${GAMES_USER_DED} --with-server-gid=${GAMES_GROUP}) \
		$(use_enable editor) \
		$(use_enable tools) \
		$(use_enable nls) \
		$(use_enable nls dummy-locales) \
		$(use_enable !dedicated game) \
		$(use_with gnome) \
		$(use_with kde) \
		|| die
	emake || die "emake failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"
	dodoc MANUAL changelog
	if use server; then
		keepdir "${GAMES_STATEDIR}/run/wesnothd"
		doinitd "${T}"/wesnothd || die "doinitd failed"
	fi
	prepgamesdirs
}
