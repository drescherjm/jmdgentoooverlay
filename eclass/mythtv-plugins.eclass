# Copyright 1999-2004 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/eclass/mythtv-plugins.eclass,v 1.12 2006/02/27 07:59:57 cardoe Exp $
#
# Author: Doug Goldstein <cardoe@gentoo.org>
#

inherit multilib

IUSE="debug mmx"

EXPORT_FUNCTIONS src_unpack src_compile src_install
MYTHPLUGINS="mythbrowser mythcontrols mythdvd mythflix mythgallery mythgame mythmusic mythnews mythphone mythvideo mythweather mythweb mytharchive"
MTVCONF=""
S="${WORKDIR}/mythplugins-${PV}"

RDEPEND="=media-tv/mythtv-${PV}*"
DEPEND="${RDEPEND}
	>=sys-apps/sed-4"

mythtv-plugins_src_unpack() {
	unpack ${A}
	cd ${S}

	sed -e 's!PREFIX = /usr/local!PREFIX = /usr!' \
	-i 'settings.pro' || die "fixing PREFIX to /usr failed"

	sed -e "s!QMAKE_CXXFLAGS_RELEASE = -O3 -march=pentiumpro -fomit-frame-pointer!QMAKE_CXXFLAGS_RELEASE = ${CXXFLAGS}!" \
	-i 'settings.pro' || die "Fixing QMake's CXXFLAGS failed"

	sed -e "s!QMAKE_CFLAGS_RELEASE = \$\${QMAKE_CXXFLAGS_RELEASE}!QMAKE_CFLAGS_RELEASE = ${CFLAGS}!" \
	-i 'settings.pro' || die "Fixing Qmake's CFLAGS failed"

	find ${S} -name '*.pro' -exec sed -i \
		-e "s:\$\${PREFIX}/lib/:\$\${PREFIX}/$(get_libdir)/:g" \
		-e "s:\$\${PREFIX}/lib$:\$\${PREFIX}/$(get_libdir):g" \
	{} \;
}

mythtv-plugins_src_compile() {
	cd ${S}

	if use debug; then
		sed -e 's!CONFIG += release!CONFIG += debug!' \
		-i 'settings.pro' || die "switching to debug build failed"
	fi

#	if ( use x86 && ! use mmx ) || ! use amd64 ; then
	if ( ! use mmx ); then
		sed -e 's!DEFINES += HAVE_MMX!DEFINES -= HAVE_MMX!' \
		-i 'settings.pro' || die "disabling MMX failed"
	fi

	local myconf=""

	if hasq ${PN} ${MYTHPLUGINS} ; then
		for x in ${MYTHPLUGINS} ; do
			if [[ ${PN} == ${x} ]] ; then
				myconf="${myconf} --enable-${x}"
			else
				myconf="${myconf} --disable-${x}"
			fi
		done
	else
		die "Package ${PN} is unsupported"
	fi

	econf ${myconf} ${MTVCONF}

	${QTDIR}/bin/qmake QMAKE="${QTDIR}/bin/qmake" -o "Makefile" mythplugins.pro || die "qmake failed to run"
	emake || die "make failed to compile"
}

mythtv-plugins_src_install() {
	if hasq ${PN} ${MYTHPLUGINS} ; then
		cd ${S}/${PN}
	else
		die "Package ${PN} is unsupported"
	fi

	einstall INSTALL_ROOT="${D}"
	for doc in AUTHORS COPYING FAQ UPGRADING ChangeLog README; do
		test -e "${doc}" && dodoc ${doc}
	done
}
