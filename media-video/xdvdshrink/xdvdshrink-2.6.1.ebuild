# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils
DESCRIPTION="This is a ebuild for XDVDShrink"
HOMEPAGE="http://dvdshrink.sourceforge.net"
SRC_URI="http://mesh.dl.sourceforge.net/sourceforge/dvdshrink/dvdshrink-${PV}-3mdk.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86"
IUSE="X"

DEPEND="\
media-video/transcode \
media-video/mjpegtools \
media-video/subtitleripper \
virtual/cdrtools \
media-video/dvdauthor \
app-cdr/dvd+rw-tools \
app-text/gocr \
dev-perl/gtk2-perl \
"

#RDEPEND=""

src_install() {

        into /usr
        dobin ${WORKDIR}/dvdshrink/usr/bin/*
        dodir /usr/share
        cp -R ${WORKDIR}/dvdshrink/usr/share/* ${D}/usr/share || die

} 
