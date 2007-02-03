# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit myth-svn

DESCRIPTION="Homebrew PVR project"
HOMEPAGE="http://www.mythtv.org/"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE="alsa altivec arts cle266 debug directfb dvb ieee1394 jack joystick lcd lirc nvidia oggvorbis opengl oss profile xv X directx ieee1394"

PROVIDE="virtual/mythtvlibs"

DEPEND=">=media-libs/freetype-2.0
	>=media-sound/lame-3.93.1
	>=x11-libs/qt-3.1
	dev-db/mysql
	alsa? ( >=media-libs/alsa-lib-0.9 )
	>=sys-apps/sed-4
	arts? ( kde-base/arts )
	directfb? ( dev-libs/DirectFB )
	dvb? ( media-libs/libdvb )
	lirc? ( app-misc/lirc )
	nvidia? ( media-video/nvidia-glx )
	jack? ( media-sound/jack-audio-connection-kit )
	ieee1394? ( sys-libs/libraw1394 )
	lcd? ( app-misc/lcdproc )
	opengl? ( virtual/opengl )
	|| ( >=net-misc/wget-1.9.1 >=media-tv/xmltv-0.5.34 )"

RDEPEND="${DEPEND}
	!media-tv/mythtv
	!media-tv/mythtv-cvs
	!media-tv/mythfrontend
	!media-tv/mythfrontend-cvs
	!media-tv/mythfrontend-svn"

[ -z "${MYTHTV_SVN_REVISION}" ] || ESVN_FETCH_CMD="svn checkout --revision ${MYTHTV_SVN_REVISION}"
[ -z "${MYTHTV_SVN_REVISION}" ] || ESVN_UPDATE_CMD="svn update --revision ${MYTHTV_SVN_REVISION}"

pkg_setup() {
	ENTRIES=/usr/portage/distfiles/svn-src/mythtv/mythtv/.svn/entries
	if [ -f "${ENTRIES}" ] ; then
		local REV=$(grep '  revision="' ${ENTRIES} | sed -e 'sX^[^"]*XX' -e 'sX".*XX' )
		if [ -n "${MYTHTV_SVN_REVISION}" ] && [ "${REV}" != "${MYTHTV_SVN_REVISION}" ] ; then
			touch -t 199901010101 ${ENTRIES}
		fi
		local NOW=$(date +%s) UPDATE=$(date -r ${ENTRIES} +%s) INTERVAL=3600
		if (( ${NOW} - ${UPDATE} <= ${INTERVAL} )); then
			echo
			ewarn "You ran this within 1 hour of your last build,"
	        	ewarn "so it will skip the update.  To bypass this:"
			ewarn " touch -t 199901010101 ${ENTRIES}"
			echo
		fi
	fi

	if ! built_with_use x11-libs/qt mysql ; then
		eerror "Qt is missing MySQL support. Please add"
		eerror "'mysql' to your USE flags, and re-emerge Qt."
		die "Qt needs MySQL support"
	fi

	if use ieee1394; then
		echo
		ewarn "If you want to USE ieee1394, you need to install libiec61883"
		ewarn "which is not available in Portage at this time. Do this at your"
		ewarn "own risk. No Support provided."
		echo
	fi

	if use nvidia; then
		echo
		ewarn "You enabled the 'nvidia' USE flag, you must have a GeForce 4 or"
		ewarn "greater to use this. Otherwise, you'll have crashes with MythTV"
		echo
	fi

}

src_unpack() {
	myth-svn_src_unpack || die "unpack failed"

	cd ${S}
}

setup_pro() {
	return 0
}

src_compile() {
	use cle266 && use nvidia && die "You can not have USE="cle266" and USE="nvidia" at the same time. Must disable one or the other."
	use debug && use profile && die "You can not have USE="debug" and USE="profile" at the same time. Must disable one or the other."

	myconf="
	    $(use_enable alsa audio-alsa)
	    $(use_enable altivec)
	    $(use_enable arts audio-arts)
	    $(use_enable cle266 xvmc-vld)
	    $(use_enable directfb)
	    $(use_enable directx)
	    $(use_enable dvb)
	    $(use_enable dvb dvb-eit)
	    $(use_enable ieee1394 firewire)
	    $(use_enable jack audio-jack)
	    $(use_enable joystick joystick-menu)
	    $(use_enable lirc)
	    $(use_enable nvidia xvmc)
	    $(use_enable opengl opengl-vsync)
	    $(use_enable oss audio-oss)
	    $(use_enable xv)
	    $(use_enable X x11)
	"

	use debug && myconf="${myconf} --compile-type=debug"
	use profile && myconf="${myconf} --compile-type=profile"

	myth-svn_src_compile
}

src_install() {
	myth-svn_src_install || die "install failed"
	
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
