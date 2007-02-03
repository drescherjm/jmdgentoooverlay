# Copyright 1999-2004 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $
# Nonofficial ebuild by Ycarus, additions by Oliver Schneider. For new version look here : http://gentoo.zugaina.org/

inherit eutils

MY_PV="211jo"
MY_P="${PN}-${MY_PV}"
DESCRIPTION="A menu driven installer for installing Windows programs under the x86 (Athlon or Intel PC) processor architecture with the Linux operatin system using Wine."
DESCRIPTION_FR="Un installateur pour des programmes Windows sous Wine."
HOMEPAGE="http://www.von-thadden.de/Joachim/WineTools/"
SRC_URI="http://ds80-237-203-29.dedicated.hosteurope.de/wt/${MY_P}.tar.gz"

RESTRICT="nomirror"
LICENSE="GPL-2"
KEYWORDS="~x86 ~amd64 ~ppc"
IUSE=""

DEPEND="app-emulation/wine
	>=sys-devel/gettext-0.14.1
	x11-libs/gtk+"

S=${WORKDIR}/winetools

src_install() {
    sed -i 's:/usr/local/winetools:/usr/share/winetools:' findwine wt${MY_PV}
    dodir /usr/share /usr/bin
    mv ${S} ${D}/usr/share
    cat << EOF > ${D}/usr/bin/winetools
#!/bin/sh
cd /usr/share/winetools
./wt${MY_PV}
EOF
    dosym /usr/share/winetools/findwine /usr/bin/
    chmod go+rx ${D}/usr/bin/winetools
}

