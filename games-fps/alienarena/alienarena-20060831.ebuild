# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils toolchain-funcs games

RUN_FILE="${PN}-2007-x86.run"

DESCRIPTION="The ultimate freeware deathmatch fragfest!"
HOMEPAGE="http://red.planetarena.org/"
SRC_URI="ftp://ftp.planetmirror.com/pub/moddb/2006/08/${RUN_FILE}
	http://www.forsakenweb.com/gamepage/loaders/games/${RUN_FILE}
	http://www.alienarena.org/downloads/${RUN_FILE}"

LICENSE="free-noncomm"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="debug opengl sdl"

UIRDEPEND="media-libs/jpeg
	virtual/glu
	virtual/opengl
	sdl? ( >=media-libs/libsdl-1.2.8-r1 )
	|| ( (
			x11-libs/libX11
			x11-libs/libXau
			x11-libs/libXdmcp
			x11-libs/libXext
			x11-libs/libXxf86dga
			x11-libs/libXxf86vm )
		virtual/x11 )
	amd64? ( app-emulation/emul-linux-x86-sdl )"
RDEPEND="opengl? ( ${UIRDEPEND} )
	sdl? ( ${UIRDEPEND} )
	!games-fps/alienarena-bin"
DEPEND="${RDEPEND}
	x11-proto/xf86dgaproto
	x11-proto/xf86vidmodeproto
	x11-proto/xproto"

S=${WORKDIR}/source/linux
dir=${GAMES_DATADIR}/${PN}
libdir=${GAMES_LIBDIR}/${PN}

pkg_setup() {
	games_pkg_setup

	echo
	ewarn "If the compilation fails, the alienarena-bin ebuild is available."
	ewarn "   http://forums.gentoo.org/viewtopic-t-493983.html"
	echo
}

src_unpack() {
	unpack_makeself ${RUN_FILE}
	unpack ./*.{bz2,gz}

	# Startup scripts
	cp -rf bin/Linux/x86/glibc-2.1/* . || die
	cp AlienArena{,.sdl}
	sed -i AlienArena.sdl -e "s:crx:crx.sdl:" \
		|| die "sed AlienArena.sdl failed"

	cd "${S}"

	# Directory for library file
	sed -i sys_linux.c \
		-e "s:path = FS_NextPath (path):path = \"${libdir}\":" \
		|| die "sed sys_linux.c failed"

	# Directory for executables
	sed -i Makefile{,.org} \
		-e "s:debug\$(ARCH):release:" \
		-e "s:release\$(ARCH):release:" \
		|| die "sed Makefile release failed"

	local sdlsound=0
	use sdl && sdlsound=1
	# Explicitly set sdl
	sed -i Makefile{,.org} \
		-e "s:\$(strip \$(SDLSOUND)):${sdlsound}:" \
		|| die "sed Makefile sdl failed"
}

src_compile() {
	local target="release"
	use debug && target="debug"

	emake \
		CC="$(tc-getCC)" \
		build_${target} \
		|| die "emake failed"
}

src_install() {
	local icon=${PN}.xpm
	doicon "${WORKDIR}/${icon}" || die "doicon failed"

	local arch_ext="i386"
	use amd64 && arch_ext="x86_64"
	exeinto "${libdir}"
	doexe "release/game${arch_ext}.so" || die "doexe game${arch_ext}.so failed"

	exeinto "${dir}"
	doexe release/crded || die "doexe crded failed"
	doexe release/crx || die "doexe crx failed"
	if use sdl ; then
		doexe release/crx.sdl || die "doexe crx.sdl failed"
	fi

	# Always install the dedicated executable
	exeinto "${dir}"
	doexe "${WORKDIR}"/AlienArenaDedicated \
		|| die "doexe AlienArenaDedicated failed"
	games_make_wrapper ${PN}-ded ./AlienArenaDedicated "${dir}"

	if use opengl || use sdl ; then
		# SDL implies OpenGL
		exeinto "${dir}"
		doexe "${WORKDIR}"/AlienArena \
			|| die "doexe AlienArena failed"
		if use sdl ; then
			doexe "${WORKDIR}"/AlienArena.sdl \
				|| die "doexe AlienArena.sdl failed"
			games_make_wrapper ${PN}-sdl ./AlienArena.sdl "${dir}"
			# Distinguish between OpenGL and SDL versions
			make_desktop_entry ${PN} "Alien Arena (OpenGL)" "${icon}"
			make_desktop_entry ${PN}-sdl "Alien Arena (SDL)" "${icon}"
		else
			make_desktop_entry ${PN} "Alien Arena" "${icon}"
		fi
		games_make_wrapper ${PN} ./AlienArena "${dir}"
	fi

	# Install
	insinto "${dir}"
	exeinto "${dir}"
	doins -r "${WORKDIR}"/{arena,botinfo,data1} || die "doins -r failed"

	dodoc "${WORKDIR}"/*.txt

	prepgamesdirs
}
