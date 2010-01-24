# Copyright 2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit toolchain-funcs

DESCRIPTION="Cablseswig: A SWIG specifically generated for ITK"
HOMEPAGE="http://www.itk.org"
SRC_URI="mirror://sourceforge/itk/CableSwig-ITK-${PV}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64"
IUSE="sysgccxml"

RDEPEND="sysgccxml? ( >=dev-cpp/gccxml-0.9 )"
DEPEND="${RDEPEND}
	>=dev-util/cmake-2.6
	"

MY_PN=CableSwig-ITK
S="${WORKDIR}/${MY_PN}-${PV}"

src_unpack() {
	unpack ${A}
	echo "${S}"
	cd "${S}"
}

src_compile() {

	local CMAKE_VARIABLES=""
	CMAKE_VARIABLES="${CMAKE_VARIABLES} -DCMAKE_INSTALL_PREFIX:PATH=/usr"
	if use sysgccxml; then
		CMAKE_VARIABLES="${CMAKE_VARIABLES} -DCSWIG_USE_SYSTEM_GCCXML=ON"
	else
		CMAKE_VARIABLES="${CMAKE_VARIABLES} -DCSWIG_USE_SYSTEM_GCCXML=OFF"
	fi

	echo -n "cmake_vars:"
	echo "${CMAKE_VARIABLES}"

	# Run CMake twice to configure properly with CMake 2.2.x
	cmake ${CMAKE_VARIABLES}  . || die "cmake configuration failed"
	emake || die "emake failed"

}

src_install() {

	cd "${S}"

	make DESTDIR="${D}" install || die "make install failed"
}
