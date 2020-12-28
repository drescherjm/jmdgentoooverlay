# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7
PYTHON_COMPAT=( python2_7 )
# From mythplugins ebuild:
# PYTHON_REQ_USE="xml"
# This is added in below for now, but will need updating once Myth moves to Python 3
# Also, I'm not sure which of the plugins (if any) actually require that, but we don't want
# to force it for systems not running plugins.

# Specify a specific commit to download.  If we just pull the latest from the branch, the ebuild
# digest will break.  Update this periodically.  When updating, keep old versions so that the
# ebuild will work on all of them with simple renaming.
if [ "${PV%.*}" == 29 ]; then
	# https://github.com/MythTV/mythtv/commits/fixes/29
	# BACKPORTS="d8a2db77f5731cf32c6d31127452391c6cf7f91f" # October 15, 2018
	BACKPORTS="8f37aa3a70763f190872191715a5b97e2f07e9c2" # February 19, 2019
elif [ "${PV%.*}" == 30 ]; then
	# https://github.com/MythTV/mythtv/commits/fixes/30
	# BACKPORTS="e3474f8afb7191d5593d5fa5baac24611842bbec" # February 25, 2019
	BACKPORTS="042c180902bcdcf58ac12cef45a9cf0e5f348912" # March 7, 2019
fi
MY_P=${P%_p*}
MY_PV=${PV%_p*}

PATCHES=(
	"${FILESDIR}"/${P}-configure-NVCtrl.patch
)

inherit eutils flag-o-matic python-single-r1 qmake-utils user readme.gentoo-r1 systemd vcs-snapshot

MYTHTV_BRANCH="fixes/${P%.*}"

DESCRIPTION="Homebrew PVR project"
HOMEPAGE="https://www.mythtv.org"
SRC_URI="https://github.com/MythTV/mythtv/archive/${BACKPORTS}.tar.gz -> ${PF}.tar.gz"

LICENSE="GPL-2"
KEYWORDS="~amd64 ~x86"
SLOT="0/${PV}"

MYTHPLUGINS="mytharchive mythbrowser mythgallery mythgame mythmusic mythnetvision
	mythnews mythweather mythzoneminder"
IUSE_INPUT_DEVICES="input_devices_joystick"
# Fixme: These should be video_capture_... flags to keep the separate, but I'm not sure
# creating a new flag category is appropriate for just this ebuild, and several of the flags
# already exist in other ebuilds
IUSE_VIDEO_CAPTURE_DEVICES="v4l ivtv ieee1394 hdpvr dvb hdhomerun vbox ceton"
IUSE="alsa altivec autostart bluray cdda cdr cec debug dvd egl exif fftw jack java lcd libass
	lirc perl pulseaudio python raw systemd vaapi vdpau vpx +wrapper x264 x265 +xml xmltv +xvid
	zeroconf zmserver ${IUSE_INPUT_DEVICES} ${IUSE_VIDEO_CAPTURE_DEVICES} ${MYTHPLUGINS}"
# Notes on use flags:
# 'frontend' and 'backend' used to be separately configurable, but options were removed due to
# "abuse in Gentoo ebuild."   It would be nice to get them back in as opitons, and then split
# the dependencies up for backend or frontend-only systems.
# We could make 'xv' and 'opengl' be use flags, but I don't think anyone would want them
# disabled, and there might be implications I'm not aware of.
# It might make sense to have a use flag to indicate if a local mysql database is to be used
# as opposed to a remote database.  The common case of a local database is assumed, but this
# installs more stuff than is needed for additional backends and frontend-only installs.

REQUIRED_USE="
	python? ( ${PYTHON_REQUIRED_USE} )
	bluray? ( xml )
	mythnetvision? ( python )
	mythnews? ( mythbrowser )
	cdr? ( cdda )
"

#
# Notes on dependencies:
#
# qtcore ... libXext, these are checked in the configure script in that order.
# qtsql qtxml qtopengl: should be checked in configure, but aren't
# glib zlib ... qtwidgets: also dependencies of other ebuilds; not sure if needed explicitly here
# libXv: Uses it if present, not sure who would run without it, could add 'xv' use flag
# qtdbus wmctrl: Builds without them, but were in an older ebuild, probably for good reason
#
# The dependencies in the plugins include many that are common to all of them because they
# were common dependencies in the old separate ebuild.  It's not clear which ebuilds actually
# require them.  Someone more familiar with them can probably pare them down.  In any case,
# the libpng and openssl dependencies appear to be redundant as they're already dependencies of
# other libraries.  I'm guessing udev is for music to detect CD insertions, but that's probably
# needed by the frontend for DVD insertion detection.  I have no idea where the util-linux
# dependency comes from.
#
COMMON="
	dev-qt/qtcore:5
	media-libs/taglib
	>=media-sound/lame-3.98.3
	virtual/opengl
	media-libs/freetype:2[X]
	media-gfx/exiv2:=
	dev-qt/qtwebkit:5
	dev-qt/qtscript:5
	x11-libs/libX11
	x11-libs/libXxf86vm
	x11-libs/libXinerama
	x11-libs/libXext
	media-libs/libsamplerate
	>=media-libs/libbluray-0.9.3
	dev-libs/lzo

	dev-qt/qtsql:5[mysql]
	dev-qt/qtxml:5
	dev-qt/qtopengl:5

	dev-libs/glib:2
	sys-libs/zlib
	x11-libs/libXrandr
	dev-qt/qtgui:5
	dev-qt/qtnetwork:5
	dev-qt/qtwidgets:5

	x11-libs/libXv

	dev-qt/qtdbus:5
	x11-misc/wmctrl

	alsa? ( >=media-libs/alsa-lib-1.0.16 )
	bluray? (
		dev-libs/libcdio:=
		sys-fs/udisks:2
	)
	cec? ( dev-libs/libcec )
	dvb? (
		virtual/linuxtv-dvb-headers
	)
	dvd? (
		dev-libs/libcdio:=
		sys-fs/udisks:2
	)
	egl? ( media-libs/mesa[egl] )
	fftw? ( sci-libs/fftw:3.0=[threads] )
	hdhomerun? ( media-libs/libhdhomerun )
	vpx? ( <media-libs/libvpx-1.7.0:= )
	x264? (	>=media-libs/x264-0.0.20111220:= )
	x265? (	media-libs/x265 )
	ieee1394? (
		>=media-libs/libiec61883-1.0.0
		>=sys-libs/libavc1394-0.5.3
		>=sys-libs/libraw1394-1.2.0
	)
	jack? ( media-sound/jack-audio-connection-kit )
	java? ( dev-java/ant )
	lcd? ( app-misc/lcdproc )
	libass? ( >=media-libs/libass-0.9.11:= )
	lirc? ( app-misc/lirc )
	perl? (
		>=dev-perl/libwww-perl-5
		dev-perl/DBD-mysql
		dev-perl/HTTP-Message
		dev-perl/IO-Socket-INET6
		dev-perl/LWP-Protocol-https
		dev-perl/Net-UPnP
	)
	pulseaudio? ( media-sound/pulseaudio )
	python? (
		${PYTHON_DEPS}
		dev-python/lxml
		dev-python/mysql-python
		dev-python/urlgrabber
		dev-python/future
		dev-python/requests-cache
	)
	systemd? ( sys-apps/systemd:= )
	vaapi? ( x11-libs/libva:=[opengl] )
	vdpau? ( x11-libs/libvdpau )
	xml? ( >=dev-libs/libxml2-2.6.0 )
	xvid? ( >=media-libs/xvid-1.1.0 )
	zeroconf? (
		dev-libs/openssl:0=
		net-dns/avahi[mdnsresponder-compat]
	)
	mytharchive? (
		app-cdr/dvd+rw-tools
		dev-python/pillow
		media-video/dvdauthor
		media-video/mjpegtools[png]
		media-video/transcode
		virtual/cdrtools
		media-libs/libpng:0=
		sys-apps/util-linux
		virtual/libudev:=
	)
	mythbrowser? (
		dev-libs/openssl:=
		media-libs/libpng:0=
		sys-apps/util-linux
		virtual/libudev:=
	)
	mythgallery? (
		media-libs/tiff:0
		exif? ( >media-libs/libexif-0.6.9:= )
		raw? ( media-gfx/dcraw )
		dev-libs/openssl:=
		media-libs/libpng:0=
		sys-apps/util-linux
		virtual/libudev:=
	)
	mythgame? (
		sys-libs/zlib[minizip]
		dev-libs/openssl:=
		media-libs/libpng:0=
		sys-apps/util-linux
		virtual/libudev:=
	)
	mythmusic? (
		>=media-libs/flac-1.1.2
		media-libs/libogg
		>=media-libs/libvorbis-1.0
		cdda? (
			dev-libs/libcdio:=
			cdr? ( virtual/cdrtools )
		)
		dev-libs/openssl:=
		media-libs/libpng:0=
		sys-apps/util-linux
		virtual/libudev:=
	)
	mythnetvision? (
		${PYTHON_DEPS}
		dev-python/lxml
		dev-python/mysql-python
		dev-python/oauth
		dev-python/pycurl
		dev-lang/python:2.7[xml]
		dev-libs/openssl:=
		media-libs/libpng:0=
		sys-apps/util-linux
		virtual/libudev:=
	)
	mythweather? (
		dev-perl/Date-Manip
		dev-perl/DateTime
		dev-perl/DateTime-Format-ISO8601
		dev-perl/Image-Size
		dev-perl/JSON
		dev-perl/SOAP-Lite
		dev-perl/XML-Parser
		dev-perl/XML-SAX
		dev-perl/XML-Simple
		dev-perl/XML-XPath
		dev-libs/openssl:=
		media-libs/libpng:0=
		sys-apps/util-linux
		virtual/libudev:=
	)
	mythzoneminder? (
		dev-libs/openssl:=
		media-libs/libpng:0=
		sys-apps/util-linux
		virtual/libudev:=
	)
"
RDEPEND="${COMMON}
	!media-tv/mythtv-bindings
	!x11-themes/mythtv-themes
	!media-plugins/mytharchive
	!media-plugins/mythbrowser
	!media-plugins/mythgallery
	!media-plugins/mythgame
	!media-plugins/mythmovies
	!media-plugins/mythmusic
	!media-plugins/mythnetvision
	!media-plugins/mythnews
	!media-plugins/mythweather
	!media-plugins/mythplugins
	media-fonts/corefonts
	media-fonts/dejavu
	media-fonts/liberation-fonts
	x11-apps/xinit
	autostart? (
		net-dialup/mingetty
		x11-apps/xset
		x11-wm/evilwm
	)
	dvd? ( media-libs/libdvdcss )
	xmltv? ( >=media-tv/xmltv-0.5.43 )
"
DEPEND="${COMMON}
	virtual/pkgconfig
	x11-base/xorg-proto
	dev-lang/yasm
"

S_MYTHTV="${WORKDIR}/${PF}/mythtv"
S_MYTHPLUGINS="${WORKDIR}/${PF}/mythplugins"
S="${S_MYTHTV}"

DISABLE_AUTOFORMATTING="yes"
DOC_CONTENTS="
To have this machine operate as recording host for MythTV,
mythbackend must be running. Run the following:
rc-update add mythbackend default

Your recordings folder must be owned 'mythtv'. e.g.
chown -R mythtv /var/lib/mythtv

Want mythfrontend to start automatically?
Set USE=autostart. Details can be found at:
https://dev.gentoo.org/~cardoe/mythtv/autostart.html

Note that the systemd unit now restarts by default and logs
to journald via the console at the notice verbosity.
"

MYTHTV_GROUPS="video,audio,tty,uucp"

pkg_setup() {
	python-single-r1_pkg_setup
	enewuser mythtv -1 /bin/bash /home/mythtv ${MYTHTV_GROUPS}
	usermod -a -G ${MYTHTV_GROUPS} mythtv
}

src_prepare() {
	default

	# Perl bits need to go into vender_perl and not site_perl
	sed -e "s:pure_install:pure_install INSTALLDIRS=vendor:" \
		-i "${S}"/bindings/perl/Makefile

	# Fix up the version info since we are using the fixes/${PV} branch
	echo "SOURCE_VERSION=\"v${MY_PV}\"" > "${S}"/VERSION
	echo "BRANCH=\"${MYTHTV_BRANCH}\"" >> "${S}"/VERSION
	echo "SOURCE_VERSION=\"${BACKPORTS}\"" > "${S}"/EXPORTED_VERSION
	echo "BRANCH=\"${MYTHTV_BRANCH}\"" >> "${S}"/EXPORTED_VERSION

	echo "setting.extra -= -ldconfig" >> "${S}"/programs/mythfrontend/mythfrontend.pro

	# Fix up any plugins that need patching
	if use ${MYTHPLUGINS}; then
		sed -i '1i#define OF(x) x' "${S_MYTHPLUGINS}"/mythgame/mythgame/external/ioapi.h
		# Patch plugins configure script to use configuration we just did above
		sed -i -e 'sX[$]prefix/include/mythtv/mythconfig.makX../mythtv/libs/libmythbase/mythconfig.makX' "${S_MYTHPLUGINS}/configure"
		# Patch plugins configure script to ignore MythTV Python bindings.  It will try to find
		# them installed, but we're just about to build them.  We know from the use flags that
		# we configured it if needed.
		sed -i -e '/check_py_lib MythTV.*disable_netvision/d' "${S_MYTHPLUGINS}/configure"
	fi
}

src_configure() {
	src_configure_mythtv
	if use ${MYTHPLUGINS}; then
		cd "${S_MYTHPLUGINS}"
		src_configure_plugins || die "configure mythplugins died"
		cd "${S_MYTHTV}"
	fi
}

src_configure_mythtv() {
	local myconf=

	#
	# Set up configuration options in the same order they are reported by the configure script.
	#

	# Setup paths
	myconf="${myconf} --prefix=${EPREFIX}/usr"
	myconf="${myconf} --libdir=${EPREFIX}/usr/$(get_libdir)"
	myconf="${myconf} --libdir-name=$(get_libdir)"
	myconf="${myconf} --mandir=${EPREFIX}/usr/share/man"

	# CPU settings
	for i in $(get-flag march) $(get-flag mcpu) $(get-flag mtune) ; do
		[ "${i}" = "native" ] && i="host"
		myconf="${myconf} --cpu=${i}"
		break
	done
	myconf="${myconf} $(use_enable altivec)" # This is only for PPC, not x86.  Who uses this?

	# Input Support
	myconf="${myconf} $(use_enable input_devices_joystick joystick-menu)"
	myconf="${myconf} $(use_enable lirc)"
	myconf="${myconf} $(use_enable cec libcec)"
	myconf="${myconf} $(use_enable v4l v4l2)"
	myconf="${myconf} $(use_enable ivtv)"
	myconf="${myconf} $(use_enable hdpvr)"
	myconf="${myconf} $(use_enable ieee1394 firewire)"
	myconf="${myconf} $(use_enable dvb)"
	myconf="${myconf} --dvb-path=/usr/include"
	# DVB-S2 support? (autodetected if DVB supports it)
	myconf="${myconf} $(use_enable hdhomerun)"
	myconf="${myconf} $(use_enable vbox)"
	myconf="${myconf} $(use_enable ceton)"
	# myconf="${myconf} $(use_enable dveo asi)"
	# DVEO ASI support will be included if header files are already installed
	# It doesn't appear to be in portage, so we don't use a use flag/dependency

	# Sound Output Support
	myconf="${myconf} $(use_enable pulseaudio audio-pulseoutput)"
	# OSS support?
	myconf="${myconf} $(use_enable alsa audio-alsa)"
	myconf="${myconf} $(use_enable jack audio-jack)"
	myconf="${myconf} $(use_enable fftw libfftw3)"

	# Video Output Support
	myconf="${myconf} --enable-x11"
	# xnvctrl support?
	myconf="${myconf} --enable-xrandr"
	myconf="${myconf} --enable-xv"
	myconf="${myconf} $(use_enable vdpau)"
	myconf="${myconf} $(use_enable vaapi)"
	# VAAPI2 support?
	# Crystal HD support? myconf="${myconf} $(use_enable crystalhd)"
	#   The Broadcom CrystalHD hardware decoder requires <libcrystalhd/libcrystalhd_if.h>
	#   If someone creates a package for this, we can add a dependency based on a use flag.
	# OpenMAX support?
	myconf="${myconf} --enable-opengl" # Could be a use flag but everyone should have it
	# OpenGL video?
	# OpenGL ThemePainter?
	# MHEG support?
	myconf="${myconf} $(use_enable libass)"

	# Misc Features
	# Frontend: yes
	# Backend: yes
	# multi threaded libavcodec?
	# libxml2 support?
	myconf="${myconf} $(use_enable zeroconf libdns-sd)"
	# libcrypto: yes (openssl is auto-detected; no reason to disable)
	myconf="${myconf} $(use_enable zeroconf libdns-sd)"
	# OpenGL ES 2.0? [autodetected based on QT support; usually no]
	# bluray support: yes (system)
	myconf="${myconf} $(use_enable java bdjava)"  # BD-J (Bluray java)?
	# BD-J type? [j2se  or j2me]
	myconf="${myconf} $(use_enable systemd systemd_notify)"
	myconf="${myconf} $(use_enable systemd systemd_journal)"

	# Bindings
	if use perl && use python; then
		myconf="${myconf} --with-bindings=perl,python"
	elif use perl; then
		myconf="${myconf} --without-bindings=python"
		myconf="${myconf} --with-bindings=perl"
	elif use python; then
		myconf="${myconf} --without-bindings=perl"
		myconf="${myconf} --with-bindings=python"
	else
		myconf="${myconf} --without-bindings=perl,python"
	fi
	use python && myconf="${myconf} --python=${EPYTHON}"


	# External Codec Options
	myconf="${myconf} --enable-libmp3lame" # lame is not optional it is required for some broadcasts for silence detection of commercials
	myconf="${myconf} $(use_enable xvid libxvid)"
	myconf="${myconf} $(use_enable x264 libx264)"
	myconf="${myconf} $(use_enable x265 libx265)"
	myconf="${myconf} $(use_enable vpx libvpx)"

	if use debug; then
		myconf="${myconf} --compile-type=debug"
		#myconf="${myconf} --enable-debug" does nothing per sphery
		myconf="${myconf} --disable-stripping" # FIXME: does not disable for all files, only for some
	else
		myconf="${myconf} --compile-type=release"
	fi

	# Random stuff
	myconf="${myconf} --enable-nonfree" # Enable non-free libraries (none are supported currently)

	# Clean up DSO load times and other compiler bits
	myconf="${myconf} --enable-symbol-visibility"
	myconf="${myconf} --enable-pic"

	if tc-is-cross-compiler ; then
		myconf="${myconf} --enable-cross-compile --arch=$(tc-arch-kernel)"
		myconf="${myconf} --cross-prefix=${CHOST}-"
	fi

	# Build boosters
	has distcc ${FEATURES} || myconf="${myconf} --disable-distcc"
	has ccache ${FEATURES} || myconf="${myconf} --disable-ccache"


	einfo "Running ./configure ${myconf}"
	./configure \
		--cc="$(tc-getCC)" \
		--cxx="$(tc-getCXX)" \
		--ar="$(tc-getAR)" \
		--extra-cflags="${CFLAGS}" \
		--extra-cxxflags="${CXXFLAGS}" \
		--extra-ldflags="${LDFLAGS}" \
		--qmake="$(qt5_get_bindir)/qmake" \
		${myconf} || die "configure died"
}

src_configure_plugins() {
	local myconf=

	# Setup paths
	myconf="${myconf} --prefix=${EPREFIX}/usr"

	use python && myconf="${myconf} --python=${EPYTHON}"
	myconf="${myconf} $(use_enable mytharchive)"
	myconf="${myconf} $(use_enable mythbrowser)"
	myconf="${myconf} $(use_enable mythgallery)"
	myconf="${myconf} $(use_enable mythgame)"
	myconf="${myconf} $(use_enable mythmusic)"
	myconf="${myconf} $(use_enable mythnetvision)"
	myconf="${myconf} $(use_enable mythnews)"
	myconf="${myconf} $(use_enable mythweather)"
	myconf="${myconf} $(use_enable mythzoneminder)"
	use mythmusic && myconf="${myconf} $(use_enable fftw)"
	use mythmusic && myconf="${myconf} $(use_enable cdda cdio)"
	use mythgallery && myconf="${myconf} --enable-opengl"
	use mythgallery && myconf="${myconf} $(use_enable exif)"
	use mythgallery && myconf="${myconf} $(use_enable exif new-exif)"
	use mythgallery && myconf="${myconf} $(use_enable raw dcraw)"
	use mythzoneminder && myconf="${myconf} $(use_enable zmserver mythzmserver)"

	einfo "Running mythplugins/configure ${myconf}"
	# Need to add -I and -L for local directories
	# Adding these with --extra-cflags=... --extra-cxxflags=... --extra-ldflags=... doesn't work
	# Includes must be from the image (${D}) because they often refer to the file with a
	# subdirectory that is different from the source location.
	MYTHTV_INCLUDES="-I${D}usr/include -I${D}usr/include/mythtv -I${D}usr/include/mythtv/libmythservicecontracts -I${D}usr/include/mythtv/libmythui -I${D}usr/include/mythtv/metadata -I${D}usr/include/mythtv/goom"
	MYTHTV_LIBS="-L${D}usr/lib64"
	sed -i -e "/^[E]*C[PX]*FLAGS=/s#= *#=${MYTHTV_INCLUDES} #" \
		-e "/^LDFLAGS=/s#= *#=${MYTHTV_LIBS} #" \
		../mythtv/libs/libmythbase/mythconfig.mak
	./configure \
		${myconf} || return 1
	# Used to also pass these in, but they're ingnored in favor of mythconfig.mak
	#	--cc="$(tc-getCC)" \
	#	--cxx="$(tc-getCXX)" \
	#	--ar="$(tc-getAR)" \
	#	--extra-cflags="${MYTHTV_INCLUDES} ${CFLAGS}" \
	#	--extra-cxxflags="${MYTHTV_INCLUDES} ${CXXFLAGS}" \
	#	--extra-ldflags="${MYTHTV_LIBS} ${LDFLAGS}" \
	#	--qmake="$(qt5_get_bindir)/qmake" \

	# Fix target library dependency locations
	sed -i -e '/^POST_TARGETDEPS += .*libmyth/s@[$][$]{DEPLIBS}@'"${D}&@" targetdep.pro
	sed -i -e '/^LIBS +=.*-lmythbase/s@ -lmythbase@'" -Wl,-rpath-link=${D}/usr/lib64 -L${D}usr/lib64&@" programs-libs.pro
}

src_compile() {
	default
	if use ${MYTHPLUGINS}; then
		# MythTV is installed in the compile phase so that the plugins can use the
		# include files and libraries during their build, but the image directory
		# gets wiped at the start of the install phase, so it will do it again.
		src_install_mythtv pre_install

		S="${S_MYTHPLUGINS}"
		cd "${S}"
		default
		S="${S_MYTHTV}"
		cd "${S}"
	fi
}

src_install_mythtv() {
	emake STRIP="true" INSTALL_ROOT="${D}" install
	# Pre-install is run as portage, not root, so chown fails below unless we exit early
	[ "$1" == "pre_install" ] && return 0
	dodoc AUTHORS UPGRADING README
	readme.gentoo_create_doc

	insinto /usr/share/mythtv/database
	doins database/*

	newinitd "${FILESDIR}"/mythbackend.init-r2 mythbackend
	newconfd "${FILESDIR}"/mythbackend.conf-r1 mythbackend
	if use systemd; then
		systemd_newunit "${FILESDIR}"/mythbackend.service-28 mythbackend.service
	fi

	dodoc keys.txt

	keepdir /etc/mythtv
	chown -R mythtv "${ED}"/etc/mythtv
	keepdir /var/log/mythtv
	chown -R mythtv "${ED}"/var/log/mythtv

	insinto /etc/logrotate.d
	newins "${FILESDIR}"/mythtv.logrotate.d-r4 mythtv

	insinto /usr/share/mythtv/contrib
	# Ensure we don't install scripts needing the perl bindings (bug #516968)
	use perl || find contrib/ -name '*.pl' -exec rm -f {} \;
	# Ensure we don't install scripts needing the python bindings (bug #516968)
	use python || find contrib/ -name '*.py' -exec rm -f {} \;
	doins -r contrib/*

	# Install our mythfrontend wrapper which is similar to Mythbuntu's
	if use wrapper; then
		mv "${ED}/usr/bin/mythfrontend" "${ED}/usr/bin/mythfrontend.real"
		newbin "${FILESDIR}"/mythfrontend.wrapper mythfrontend
		newconfd "${FILESDIR}"/mythfrontend.conf mythfrontend
	fi

	if use autostart; then
		dodir /etc/env.d/
		echo 'CONFIG_PROTECT="/home/mythtv/"' > "${ED}"/etc/env.d/95mythtv

		insinto /home/mythtv
		newins "${FILESDIR}"/bash_profile .bash_profile
		newins "${FILESDIR}"/xinitrc-r1 .xinitrc
	fi

	# Make Python files executable
	find "${ED}/usr/share/mythtv" -type f -name '*.py' | while read file; do
		if [[ ! "${file##*/}" = "__init__.py" ]]; then
			chmod a+x "${file}"
		fi
	done

	# Ensure that Python scripts are executed by Python 2
	python_fix_shebang "${ED}/usr/share/mythtv"

	# Make shell & perl scripts executable
	find "${ED}" -type f -name '*.sh' -o -type f -name '*.pl' | \
		while read file; do
		chmod a+x "${file}"
	done
}

src_install_plugins() {
	if use ${MYTHPLUGINS}; then
		S="${S_MYTHPLUGINS}"
		cd "${S}"
		emake INSTALL_ROOT="${D}" install || die "make install failed"
		S="${S_MYTHTV}"
		cd "${S}"
	fi
}

src_install() {
	src_install_mythtv
	src_install_plugins
}

pkg_preinst() {
	export CONFIG_PROTECT="${CONFIG_PROTECT} ${EROOT}/home/mythtv/"
}

pkg_postinst() {
	readme.gentoo_print_elog
}

pkg_info() {
	if [[ -f "${EROOT}"/usr/bin/mythfrontend ]]; then
		"${EROOT}"/usr/bin/mythfrontend --version
	fi
}

pkg_config() {
	echo "Creating mythtv MySQL user and mythconverg database if it does not"
	echo "already exist. You will be prompted for your MySQL root password."
	"${EROOT}"/usr/bin/mysql -u root -p < "${EROOT}"/usr/share/mythtv/database/mc.sql
}
