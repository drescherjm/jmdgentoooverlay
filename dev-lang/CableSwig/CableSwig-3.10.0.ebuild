# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit toolchain-funcs

DESCRIPTION="NLM Insight Segmentation and Registration Toolkit"
HOMEPAGE="http://www.itk.org"
SRC_URI="mirror://sourceforge/itk/CableSwig-ITK-${PV}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE=""

RDEPEND=""
DEPEND="${RDEPEND}
		>=dev-util/cmake-2.4"

MY_PN="CableSwig-ITK"
S="${WORKDIR}/${MY_PN}-${PV}"

src_unpack() {

	unpack ${A}
	cd "${S}"

}

src_compile() {

        cd "${S}"

	local CMAKE_VARIABLES=""
	CMAKE_VARIABLES="${CMAKE_VARIABLES} -DCMAKE_INSTALL_PREFIX:PATH=/usr"

#	if use examples; then
#		CMAKE_VARIABLES="${CMAKE_VARIABLES} -DBUILD_EXAMPLES:BOOL=ON"
#	else
#		CMAKE_VARIABLES="${CMAKE_VARIABLES} -DBUILD_EXAMPLES:BOOL=OFF"
#	fi


	# Give us an optimised release build
	CMAKE_VARIABLES="${CMAKE_VARIABLES} -DCMAKE_BUILD_TYPE:STRING=RELWITHDEBINFO"

	echo -n "cmake_vars:"
	echo ${CMAKE_VARIABLES}

	# Run CMake twice to configure properly with CMake 2.2.x
	cmake ${CMAKE_VARIABLES} . && cmake ${CMAKE_VARIABLES} . 		\
		|| die "cmake configuration failed"

	emake || die "emake failed"

}

src_install() {

	cd "${S}"

	emake DESTDIR=${D} install || die "make install failed"

	dobin /usr/lib/CableSwig/bin/*
}


