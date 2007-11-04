# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-tv/mythtv/mythtv-0.21_pre14666.ebuild,v 1.1 2007/10/12 18:55:18 cardoe Exp $

inherit flag-o-matic multilib eutils qt3 mythtv subversion toolchain-funcs

DESCRIPTION="Homebrew PVR project"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~x86"

IUSE_VIDEO_CARDS="video_cards_i810 video_cards_nvidia video_cards_via"

IUSE="alsa altivec autostart dbox2 debug directv dts dvb dvd hdhomerun ieee1394 iptv ivtv jack joystick lcd lirc mmx vorbis opengl perl xvmc ${IUSE_VIDEO_CARDS}"

RDEPEND=">=media-libs/freetype-2.0
	>=media-sound/lame-3.93.1
	x11-libs/libX11
	x11-libs/libXext
	x11-libs/libXinerama
	x11-libs/libXv
	x11-libs/libXrandr
	x11-libs/libXxf86vm
	xvmc? (
		x11-libs/libXvMC
		video_cards_nvidia? ( x11-drivers/nvidia-drivers )
		video_cards_via? ( x11-drivers/xf86-video-via )
		video_cards_i810? ( x11-drivers/xf86-video-i810 )
	)
	$(qt_min_version 3.3)
	virtual/mysql
	virtual/opengl
	virtual/glu
	|| ( >=net-misc/wget-1.9.1 >=media-tv/xmltv-0.5.34 )
	alsa? ( >=media-libs/alsa-lib-0.9 )
	dts? ( || ( media-libs/libdca media-libs/libdts ) )
	dvd? ( 	media-libs/libdvdnav )
	dvb? ( media-libs/libdvb media-tv/linuxtv-dvb-headers )
	directv? ( virtual/perl-Time-HiRes )
	ivtv? ( media-tv/ivtv )
	jack? ( media-sound/jack-audio-connection-kit )
	lcd? ( app-misc/lcdproc )
	lirc? ( app-misc/lirc )
	perl? ( dev-perl/DBD-mysql )
	vorbis? ( media-libs/libvorbis )
	ieee1394? (	>=sys-libs/libraw1394-1.2.0
			>=sys-libs/libavc1394-0.5.0
			>=media-libs/libiec61883-1.0.0 )
	autostart? ( net-dialup/mingetty
				x11-wm/evilwm
				x11-apps/xset )"

DEPEND="${RDEPEND}
	x11-proto/xineramaproto
	x11-proto/xf86vidmodeproto
	x11-apps/xinit"

PDEPEND="=x11-themes/mythtv-themes-${MY_PV}*"

S="${WORKDIR}/${PN}-${MY_PV}"

MYTHTV_GROUPS="video,audio,tty,uucp"

pkg_setup() {

	local rip=0
	if ! built_with_use -a =x11-libs/qt-3* mysql opengl ; then
		echo
		eerror "MythTV requires Qt to be built with mysql and opengl use flags enabled."
		eerror "Please re-emerge =x11-libs/qt-3*, after having the use flags set."
		echo
		rip=1
	fi

	if use xvmc && use video_cards_nvidia; then
		echo
		ewarn "You enabled the 'xvmc' USE flag, you must have a GeForce 4 or"
		ewarn "greater to use this. Otherwise, you'll have crashes with MythTV"
		echo
	fi

	if use xvmc && ! ( use video_cards_i810 || use video_cards_nvidia || use video_cards_via ); then
		echo
		eerror "You enabled the XvMC USE flag but did not configure VIDEO_CARDS with either"
		eerror "an nVidia, Intel i810, or VIA video card."
		echo
		rip=1
	fi

	[[ $rip == 1 ]] && die "Please fix the above issues, before continuing."

	echo
	einfo "This ebuild now uses a heavily stripped down version of your CFLAGS"
	einfo "Don't complain because your -momfg-fast-speed CFLAG is being stripped"
	einfo "Only additional CFLAG issues that will be addressed are for binary"
	einfo "package building."
	echo
}

src_unpack() {
	subversion_src_unpack

	# As needed fix since they don't know how to write qmake let alone a real
	# make system. And they won't accept this upstream since it comes from
	# Gentoo
	#epatch "${FILESDIR}"/${PN}-0.20-as-needed.patch

	# upstream wants the revision number in their version.cpp
	# since the subversion.eclass strips out the .svn directory
	# svnversion in MythTV's build doesn't work
	sed -e "s:\`(svnversion \$\${SVNTREEDIR} 2>\/dev\/null) || echo Unknown\`:${SVNREV}:" \
		-i "${S}"/version.pro || die "svnversion sed failed"
}

src_compile() {
	local myconf="--prefix=/usr
		--mandir=/usr/share/man
		--libdir-name=$(get_libdir)"
	use alsa || myconf="${myconf} --disable-audio-alsa"
	use jack || myconf="${myconf} --disable-audio-jack"
	use dts && myconf="${myconf} --enable-libdts"
	use dbox2 || myconf="${myconf} --disable-dbox2"
	use hdhomerun || myconf="${myconf} --disable-hdhomerun"
	use altivec || myconf="${myconf} --disable-altivec"
	use xvmc && myconf="${myconf} --enable-xvmc"
	use xvmc && use video_cards_via && myconf="${myconf} --enable-xvmc-pro"
	use xvmc && ! use video_cards_nvidia && myconf="${myconf} --disable-xvmc-opengl"
	use perl && myconf="${myconf} --with-bindings=perl"
	myconf="${myconf}
		--disable-audio-arts
		$(use_enable lirc)
		$(use_enable joystick joystick-menu)
		$(use_enable dvb)
		--dvb-path=/usr/include
		$(use_enable opengl opengl-vsync)
		$(use_enable ieee1394 firewire)
		$(use_enable iptv)
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

	# let MythTV come up with our CFLAGS. Upstream will support this
	CFLAGS=""
	CXXFLAGS=""
	einfo "Running ./configure ${myconf}"
	./configure ${myconf} || die "configure died"

	${QTDIR}/bin/qmake QMAKE=${QTDIR}/bin/qmake -o "Makefile" mythtv.pro || die "qmake failed"
	emake || die "emake failed"

	# firewire support should build the tester
	if use ieee1394; then
		cd contrib
		$(tc-getCC) ${CFLAGS} ${CPPFLAGS} -o ../firewire_tester firewire_tester.c \
			${LDFLAGS} -liec61883 -lraw1394 || \
			die "failed to compile firewire_tester"

		cd channel_changers
		$(tc-getCC) ${CFLAGS} ${CPPFLAGS} -std=gnu99 -o ../../6200ch 6200ch.c \
			${LDFLAGS} -lrom1394 -lavc1394 -lraw1394 || \
			die "failed to compile 6200ch"
		$(tc-getCC) ${CFLAGS} ${CPPFLAGS} -o ../../sa3250ch sa3250ch.c \
			${LDFLAGS} -lrom1394 -lavc1394 -lraw1394 || \
			die "failed to compile sa3250ch"
#		LDLIBS="-liec61883 -lraw1394" CC=$(tc-getCC) emake firewire_tester || \
#			die	"failed to compile firewire_tester"
	fi

	cd ${S}/contrib/channel_changers
	$(tc-getCC) ${CFLAGS} ${CPPFLAGS} -o ../../red_eye red_eye.c ${LDFLAGS} || \
		die "failed to compile red_eye"
}

src_install() {

	einstall INSTALL_ROOT="${D}" || die "install failed"
	for doc in AUTHORS FAQ UPGRADING ChangeLog README; do
		test -e "${doc}" && dodoc ${doc}
	done

	insinto /usr/share/mythtv/database
	doins database/*

	exeinto /usr/share/mythtv
	doexe "${FILESDIR}/mythfilldatabase.cron"

	newinitd ${FILESDIR}/mythbackend-0.18.2.rc mythbackend
	newconfd ${FILESDIR}/mythbackend-0.18.2.conf mythbackend

	dodoc keys.txt docs/*.{txt,pdf}
	dohtml docs/*.html

	keepdir /etc/mythtv
	chown -R mythtv "${D}"/etc/mythtv
	keepdir /var/log/mythtv
	chown -R mythtv "${D}"/var/log/mythtv

	insinto /etc/logrotate.d
	newins "${FILESDIR}"/mythtv.logrotate.d mythtv

	insinto /usr/share/mythtv/contrib
	doins -r contrib/*

	insinto /usr/share/mythtv/configfiles
	doins configfiles/*

	dobin "${FILESDIR}"/runmythfe

	if use autostart; then
		dodir /etc/env.d/
		echo 'CONFIG_PROTECT="/home/mythtv/"' > ${D}/etc/env.d/95mythtv

		insinto /home/mythtv
		newins "${FILESDIR}"/bash_profile .bash_profile
		newins "${FILESDIR}"/xinitrc .xinitrc
	fi

	if use ieee1394; then
		dobin firewire_tester || die "failed to install firewire_tester"
		dodoc contrib/firewire_tester-README

		dobin 6200ch || die "failed to install 6200ch"
		dodoc contrib/channel_changers/6200ch-README

		dobin sa3250ch || die "failed to install sa3250ch"
		dodoc contrib/channel_changers/sa3250ch-README
	fi

	dobin red_eye || die "failed to install red_eye"
	dodoc contrib/channel_changers/red_eye-README

	if use directv; then
		dobin contrib/channel_changers/d10control.pl || die "failed to install d10control"
		dodoc contrib/channel_changers/d10control-README
	fi
}

pkg_preinst() {
	enewuser mythtv -1 /bin/bash /home/mythtv ${MYTHTV_GROUPS} || die "Problem adding mythtv user"
	usermod -a -G ${MYTHTV_GROUPS} mythtv

	export CONFIG_PROTECT="${CONFIG_PROTECT} ${ROOT}/home/mythtv/"
}

pkg_postinst() {
	echo
	elog "Want mythfrontend to start automatically?"
	elog "Set USE=autostart. Details can be found at:"
	elog "http://dev.gentoo.org/~cardoe/mythtv/autostart.html"

	echo
	elog "To always have MythBackend running and available run the following:"
	elog "rc-update add mythbackend default"
	echo
	ewarn "Your recordings folder must be owned by the user 'mythtv' now"
	ewarn "chown -R mythtv /path/to/store"

	if use autostart; then
		echo
		elog "Please add the following to your /etc/inittab file at the end of"
		elog "the TERMINALS section"
		elog "c8:2345:respawn:/sbin/mingetty --autologin mythtv tty8"
	fi

}

pkg_info() {
	/usr/bin/mythfrontend --version
}

pkg_config() {
	echo "Creating mythtv MySQL user and mythconverg database if it does not"
	echo "already exist. You will be prompted for your MySQL root password."
	/usr/bin/mysql -u root -p < /usr/share/mythtv/database/mc.sql
}
