# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-tv/mythfrontend/mythfrontend-0.18.ebuild,v 1.1 2005/04/18 07:41:34 eradicator Exp $

inherit myth flag-o-matic eutils toolchain-funcs

DESCRIPTION="Homebrew PVR project"
HOMEPAGE="http://www.mythtv.org/"
SRC_URI="http://www.mythtv.org/mc/mythtv-${PV}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE="alsa altivec arts cle266 directfb dvb ieee1394 jack joystick lcd lirc nvidia oggvorbis opengl oss xv X" # mmx "
S="${WORKDIR}/mythtv-${PV}"
DEPEND=">=media-libs/freetype-2.0
	>=media-sound/lame-3.93.1
	>=x11-libs/qt-3.1
	dev-db/mysql
	alsa? ( >=media-libs/alsa-lib-0.9 )
	>=sys-apps/sed-4
	arts? ( kde-base/arts )
	directfb? ( dev-libs/DirectFB )
	dvb? ( media-libs/libdvb )
	jack? ( media-sound/jack-audio-connection-kit )
	lcd? ( app-misc/lcdproc )
	lirc? ( app-misc/lirc )
	nvidia? ( media-video/nvidia-glx )
	oggvorbis? ( media-libs/libvorbis )
	opengl? ( virtual/opengl )
	|| ( >=net-misc/wget-1.9.1 >=media-tv/xmltv-0.5.34 )"

RDEPEND="${DEPEND}
	!media-tv/mythfrontend"

pkg_setup() {

	if ! built_with_use x11-libs/qt mysql ; then
		eerror "Qt is missing MySQL support. Please add"
		eerror "'mysql' to your USE flags, and re-emerge Qt."
		die "Qt needs MySQL support"
	fi

	if use nvidia; then
		echo
		ewarn "You enabled the 'nvidia' USE flag, you must have a GeForce 4 or"
		ewarn "greater to use this. Otherwise, you'll have crashes with MythTV"
		echo
	fi

}

src_unpack() {
	# Fix bugs 40964 and 42943.
	filter-flags -fforce-addr -fPIC

	# fix bug 67832, 81610, etc
	is-flag "-march=pentium4" && replace-flags "-O3" "-O2"
	is-flag "-march=pentium4" && replace-flags "-0s" "-O2"
	is-flag "-march=athlon-xp" && replace-flags "-O3" "-O2"

	myth_src_unpack || die "unpack failed"

	cd ${S}
}

setup_pro() {
	sed -e "s:CONFIG  += linux backend:CONFIG  += linux:" \
	    -i 'settings.pro' || die "Removal of mythbackend failed"
}

src_compile() {
	use cle266 && use nvidia && die "You can not have USE="cle266" and USE="nvidia" at the same time. Must disable one or the other."

	# tested on different versions on gcc, P4, celeron & athlon-xp, and all bork on postProcess_MMX
	# with mmx enabled, so disabled for all architectures for now - FIXME
	myconf="--disable-mmx
		$(use_enable altivec)

		$(use_enable oss audio-oss)
	        $(use_enable alsa audio-alsa)
	        $(use_enable arts audio-arts)
		$(use_enable jack audio-jack)
		$(use_enable lirc)
		$(use_enable joystick joystick-menu)

	        $(use_enable cle266 xvmc-vld)
	        $(use_enable directfb)
	        $(use_enable dvb)
	        $(use_enable dvb dvb-eit)
		--dvb-path=/usr/include
		$(use_enable opengl opengl-vsync)
		$(use_enable oggvorbis vorbis)
		$(use_enable nvidia xvmc)
		$(use_enable xv)
		$(use_enable X x11)"

	# $(use_enable ieee1394 firewire)

	myth_src_compile
}

src_install() {
	myth_src_install || die "install failed"
	newbin "setup/setup" "mythsetup"

	insinto /usr/share/mythtv/database
	doins database/*

	exeinto /usr/share/mythtv
	doexe "${FILESDIR}/mythfilldatabase.cron"

	exeinto /etc/init.d
	newexe "${FILESDIR}/mythbackend.rc6" mythbackend
	insinto /etc/conf.d
	newins "${FILESDIR}/mythbackend.conf" mythbackend

	dodoc keys.txt docs/*.{txt,pdf}
	dohtml docs/*.html

	keepdir /var/{log,run}/mythtv
}
