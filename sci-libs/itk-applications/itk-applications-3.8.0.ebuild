# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit distutils eutils flag-o-matic toolchain-funcs versionator

DESCRIPTION="NLM  Insight Segmentation and Registration Toolkit"
HOMEPAGE="http://www.itk.org"
SRC_URI="mirror://sourceforge/itk/InsightApplications-${PV}.tar.gz
	ftp://public.kitware.com/pub/itk/v3.8/InsightApplications-${PV}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE=""

DEPEND="sys-libs/zlib
	media-libs/jpeg
	media-libs/libpng
	media-libs/tiff
	>=sci-libs/itk-3.8"
RDEPEND="${RDEPEND}
	 >=dev-util/cmake-2.4"

S=${WORKDIR}/InsightApplications-${PV}

src_compile() {

	# Install path prefix, prepended onto install directories
	CMAKE_VARIABLES="${CMAKE_VARIABLES} -DCMAKE_INSTALL_PREFIX:PATH=/usr"
	# Build ITK with shared libraries
	CMAKE_VARIABLES="${CMAKE_VARIABLES} -DBUILD_SHARED_LIBS:BOOL=ON"
	# Don't bother building the testing tree
	CMAKE_VARIABLES="${CMAKE_VARIABLES} -DBUILD_TESTING:BOOL=OFF"
	# Give us an optimised release build
	CMAKE_VARIABLES="${CMAKE_VARIABLES} -DCMAKE_BUILD_TYPE:STRING=RELWITHDEBINFO"
	# We do not want rpath enabled
	CMAKE_VARIABLES="${CMAKE_VARIABLES} -DCMAKE_SKIP_RPATH:BOOL=ON"
	# Enable VTK: does not cost anything, as it seems.
	CMAKE_VARIABLES="${CMAKE_VARIABLES} -DUSE_VTK:BOOL=ON"

	# Run CMake twice to configure properly with CMake 2.2.x
	cmake ${CMAKE_VARIABLES} . && cmake ${CMAKE_VARIABLES} . \
		|| die "CMake configuration failed"

	emake || die "emake failed"
}

src_install() {

	# Do install
	make DESTDIR=${D} install || die "make install failed"

	# Install into different directories
	dodir /usr/share/InsightToolkit/InsightApplications/bin || \
		die "Creating destination directory failed"
	mv ${D}/usr/bin/* ${D}/usr/share/InsightToolkit/InsightApplications/bin || \
		die "Moving binaries failed"
	dodir /usr/lib/InsightToolkit || \
		die "Creating library directory failed"
	mv ${D}/usr/lib/*.so ${D}/usr/lib/InsightToolkit || \
		die "Moving libraries failed"
	dodir /usr/include/InsightToolkit/InsightApplications || \
		die "Creating include directory failed"
	mv ${D}/usr/include/ImageCalculator ${D}/usr/include/InsightToolkit/InsightApplications || \
		die "Moving header files failed"

	# Copy whole directory to /usr/share/InsightToolkit/src
	cp -r ${S} ${D}/usr/share/InsightToolkit/InsightApplications/src
}


