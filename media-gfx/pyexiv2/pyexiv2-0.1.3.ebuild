# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $
inherit eutils

DESCRIPTION="pyexiv2 is a python binding to exiv2, the C++ library for manipulation of EXIF and IPTC image metadata"
HOMEPAGE="http://tilloy.net/dev/pyexiv2/index.htm"
SRC_URI="http://tilloy.net/dev/pyexiv2/releases/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE=""

DEPEND=">=dev-lang/python-2.5.1
	>=media-gfx/exiv2-0.18
	>=dev-libs/boost-1.34.1
	dev-util/scons"

RDEPEND="${DEPEND}"

S=${WORKDIR}/${P}

src_unpack() {
	unpack ${A}
	cd "${S}"
}

src_compile() {
	cd "${S}"
	scons || die " Build Failed"
}

src_install() {
	cd "${S}"
	scons DESTDIR=${D} install || die "Install Failed"
}
