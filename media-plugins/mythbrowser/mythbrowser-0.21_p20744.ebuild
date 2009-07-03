# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-plugins/mythbrowser/mythbrowser-0.21_p16468.ebuild,v 1.2 2009/07/01 13:54:13 cardoe Exp $

EAPI=1

inherit mythtv-plugins kde-functions multilib

DESCRIPTION="Web browser module for MythTV."
IUSE=""
#KEYWORDS="~amd64 ~ppc ~x86"

# JMD: I am masking this because it did not build cleanly on my machine. I do not use this so it may be 
# some time before I fix it.
KEYWORDS="" 

RDEPEND="kde-base/kdelibs:3.5"
DEPEND="${RDEPEND}"

src_unpack() {
	subversion_src_unpack
	mythtv-plugins_src_unpack_patch || die "mythplugins patch failed"

	set-kdedir
	echo "INCLUDEPATH += ${KDEDIR}/include" >> settings.pro
	echo "EXTRA_LIBS += -L${KDEDIR}/$(get_libdir)" >> settings.pro
}
