# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-tv/mythtv/mythtv-0.19_p9163-r1.ebuild,v 1.7 2006/05/23 05:27:17 cardoe Exp $

inherit flag-o-matic multilib eutils debug qt3

PATCHREV=9163
#MY_PV="${PV%_*}"
MY_PV="${PV}"

DESCRIPTION="Homebrew PVR project"
HOMEPAGE="http://www.mythtv.org/"
SRC_URI="http://www.mythtv.org/mc/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 ppc x86"

IUSE_VIDEO_CARDS="video_cards_i810 video_cards_nvidia video_cards_via"

IUSE="alsa altivec arts backendonly debug dbox2 dvb dvd frontendonly ieee1394 jack joystick lcd
lirc mmx oggvorbis opengl xvmc ${IUSE_VIDEO_CARDS}"

RDEPEND=">=media-libs/freetype-2.0
	>=media-sound/lame-3.93.1
	|| ( (	x11-libs/libX11
		x11-libs/libXext
		x11-libs/libXinerama
		x11-libs/libXv
		x11-libs/libXrandr
		x11-libs/libXxf86vm
		)
	virtual/x11 )
	xvmc? (
		|| ( x11-libs/libXvMC virtual/x11 )
		video_cards_nvidia? ( media-video/nvidia-glx )
		video_cards_via? ( || ( x11-drivers/xf86-video-via virtual/x11 ) )
		video_cards_i810? ( || ( x11-drivers/xf86-video-i810 virtual/x11 ) )
	)
	$(qt_min_version 3.3)
	dev-db/mysql
	alsa? ( >=media-libs/alsa-lib-0.9 )
	arts? ( kde-base/arts )
	dvd? ( 	media-libs/libdvdnav
		media-libs/libdts )
	dvb? ( media-libs/libdvb media-tv/linuxtv-dvb-headers )
	jack? ( media-sound/jack-audio-connection-kit )
	lcd? ( app-misc/lcdproc )
	lirc? ( app-misc/lirc )
	oggvorbis? ( media-libs/libvorbis )
	opengl? ( virtual/opengl )
	ieee1394? (	>=sys-libs/libraw1394-1.2.0
			>=sys-libs/libavc1394-0.5.0
			>=media-libs/libiec61883-1.0.0 )
	|| ( >=net-misc/wget-1.9.1 >=media-tv/xmltv-0.5.34 )
	!<x11-base/xorg-x11-6.8"

DEPEND="${RDEPEND}
	|| ( x11-apps/xinit virtual/x11 )"

PDEPEND="=x11-themes/mythtv-themes-${MY_PV}*"

S="${WORKDIR}/${PN}-${MY_PV}"

MYTHTV_GROUPS="video,audio,games,tty"

pkg_setup() {

	if ! built_with_use x11-libs/qt mysql ; then
		eerror "Qt is missing MySQL support. Please add"
		eerror "'mysql' to your USE flags, and re-emerge Qt."
		die "Qt needs MySQL support"
	fi

	if ! built_with_use x11-libs/qt opengl ; then
		eerror "Qt requires OpenGL support. Please add"
		eerror "'opengl' to your USE flags, and re-emerge Qt."
		die "Qt needs OpenGL support."
	fi

	if ! has_version x11-libs/libXv && ! built_with_use x11-base/xorg-x11 xv; then
		eerror "xorg-x11 is missing XV support. Please add"
		eerror "'xv' to your USE flags, and re-emerge xorg-x11."
		die "xorg-x11 needs XV support"
	fi

	if use xvmc && use video_cards_nvidia; then
		echo
		ewarn "You enabled the 'xvmc' USE flag, you must have a GeForce 4 or"
		ewarn "greater to use this. Otherwise, you'll have crashes with MythTV"
		echo
	fi

	if has x11-libs/libX11 virtual/x11; then
		echo
		eerror "Congratulations. You've unmasked modular X but somehow managed"
		eerror "to royally screw up its installation. This means you've broke"
		eerror "dependancy checking for ALL your X based apps. You don't have"
		eerror "to believe me but don't insist the dependancies for MythTV are"
		eerror "broken, because it is you that is broken."
		die "You are broken"
	fi

	einfo
	einfo "This ebuild now uses a heavily stripped down version of your CFLAGS"
	einfo "Don't complain because your -momfg-fast-speed CFLAG is being stripped"
	einfo "Only additional CFLAG issues that will be addressed are for binary"
	einfo "package building."
	einfo
}

src_unpack() {
	unpack ${A}
	cd ${S}

	#Fixes of the bugs found in the 0.19 release
	#epatch "${WORKDIR}"/${PN}-${MY_PV}-rev${PATCHREV}.patch

	# Support installing in libdir != lib
	# epatch "${FILESDIR}/mythtv-0.19-libdir.patch"
}

src_compile() {
	local myconf="--prefix=/usr
		--mandir=/usr/share/man
		--libdir-name=$(get_libdir)"
	use alsa || myconf="${myconf} --disable-audio-alsa"
	use jack || myconf="${myconf} --disable-audio-jack"
	use altivec || myconf="${myconf} --disable-altivec"
	use xvmc && myconf="${myconf} --enable-xvmc"

# 	The following line was removed because it is not compatible with the current mythtv.
#	I am not familiar with its functionality so I leave it here.
#		$(use_enable dvb dvb-eit)

#	I'll have to check on this one later..
#		$(use_enable dvd)


	myconf="${myconf}
		$(use_enable arts audio-arts)
		$(use_enable lirc)
		$(use_enable joystick joystick-menu)
		$(use_enable dbox2)
		$(use_enable dvb)
		--dvb-path=/usr/include
		$(use_enable opengl opengl-vsync)
		$(use_enable ieee1394 firewire)
		--enable-xrandr
		--enable-xv
		--disable-directfb
		--enable-x11
		--enable-proc-opt"

	if use mmx || use amd64; then
		myconf="${myconf} --enable-mmx"
	else
		myconf="${myconf} --disable-mmx"
	fi

	if use debug; then
		myconf="${myconf} --compile-type=debug"
	else
		myconf="${myconf} --compile-type=release"
	fi

	## CFLAG cleaning so it compiles
	MARCH=$(get-flag "march")
	MTUNE=$(get-flag "mtune")
	MCPU=$(get-flag "mcpu")
	strip-flags
	filter-flags "-march=*" "-mtune=*" "-mcpu=*"
	filter-flags "-O" "-O?"

	if [[ -n "${MARCH}" ]]; then
		myconf="${myconf} --arch=${MARCH}"
	fi
	if [[ -n "${MTUNE}" ]]; then
		myconf="${myconf} --tune=${MTUNE}"
	fi
	if [[ -n "${MCPU}" ]]; then
		myconf="${myconf} --cpu=${MCPU}"
	fi

#	myconf="${myconf} --extra-cxxflags=\"${CXXFLAGS}\" --extra-cflags=\"${CFLAGS}\""
	hasq distcc ${FEATURES} || myconf="${myconf} --disable-distcc"
	hasq ccache ${FEATURES} || myconf="${myconf} --disable-ccache"

	if use frontendonly; then
		##Backend Removal
		ewarn
		ewarn "You are using the experimental feature for only installing the frontend."
		ewarn "You will not get Gentoo support nor support from MythTV upstream for this."
		ewarn "If this breaks, you own both pieces."
		ewarn
		myconf="${myconf} --disable-backend"
	fi

	if use backendonly; then
		##Frontend Removal
		ewarn
		ewarn "You are using the experimental feature for only installing the backend."
		ewarn "You will not get Gentoo support nor support from MythTV upstream for this."
		ewarn "If this breaks, you own both pieces."
		ewarn
		myconf="${myconf} --disable-frontend"
	fi

	# let MythTV come up with our CFLAGS. Upstream will support this
	CFLAGS=""
	CXXFLAGS=""
	einfo "Running ./configure ${myconf}"
	./configure ${myconf} || die "configure died"

	${QTDIR}/bin/qmake QMAKE=${QTDIR}/bin/qmake -o "Makefile" mythtv.pro || die "qmake failed"
	emake || die "emake failed"

}

src_install() {

	einstall INSTALL_ROOT="${D}" || die "install failed"
	for doc in AUTHORS COPYING FAQ UPGRADING ChangeLog README; do
		test -e "${doc}" && dodoc ${doc}
	done

	if ! use frontendonly; then
		insinto /usr/share/mythtv/database
		doins database/*

		exeinto /usr/share/mythtv
		doexe "${FILESDIR}/mythfilldatabase.cron"

		newinitd ${FILESDIR}/mythbackend-0.18.2.rc mythbackend
		newconfd ${FILESDIR}/mythbackend-0.18.2.conf mythbackend
	fi

	if ! use backendonly; then
		dobin ${FILESDIR}/runmythfe

		ewarn "Want MythFrontend to always? Add the following to your"
		ewarn "myth user. i.e. My user is mythtv"
		echo "crontab -e -u mythtv"
		echo "* * * * * /usr/bin/runmythfe &"
		ewarn "And you're all set."
	fi
	dodoc keys.txt docs/*.{txt,pdf}
	dohtml docs/*.html

	keepdir /etc/mythtv
	chown -R mythtv "${D}"/etc/mythtv
	keepdir /var/log/mythtv
	chown -R mythtv "${D}"/var/log/mythtv

	insinto /usr/share/mythtv/contrib
	doins contrib/*
}

pkg_preinst() {
	enewuser mythtv -1 "-1" -1 ${MYTHTV_GROUPS} || die "Problem adding mythtv user"
	usermod -G ${MYTHTV_GROUPS} mythtv
}

pkg_postinst() {
	einfo "Want MythFrontend to alway run? Run the following:"
	echo " #crontab -e -u mythtv"
	einfo "And add the following:"
	echo "* * * * * /usr/bin/runmythfe &"
	echo
	echo
	einfo "To always have MythBackend running and available run the following:"
	echo "rc-update add mythbackend default"
	echo
	ewarn "Your recordings folder must be owned by the user 'mythtv' now"
	echo "chown -R mythtv /path/to/store"
}

