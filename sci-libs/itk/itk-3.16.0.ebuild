# Copyright 2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit toolchain-funcs

DESCRIPTION="NLM Insight Segmentation and Registration Toolkit"
HOMEPAGE="http://www.itk.org"
SRC_URI="mirror://sourceforge/itk/InsightToolkit-${PV}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="doc examples fftw shared patented test python oldpython numpy"

RDEPEND="sys-libs/zlib
	fftw? ( sci-libs/fftw )
		media-libs/jpeg
		media-libs/libpng
		media-libs/tiff"
DEPEND="${RDEPEND}
		>=dev-util/cmake-2.6
	python? ( >=dev-util/cableswig-3.14.0
	       	   >=dev-lang/python-2.5 )
	numpy? ( dev-python/numpy )
	"

MY_PN=InsightToolkit
S="${WORKDIR}/${MY_PN}-${PV}"

src_unpack() {

	unpack ${A}
	cd "${S}"

}

src_compile() {

	local CMAKE_VARIABLES=""
	CMAKE_VARIABLES="${CMAKE_VARIABLES} -DCMAKE_INSTALL_PREFIX:PATH=/usr"

	if use fftw; then
		CMAKE_VARIABLES="${CMAKE_VARIABLES} -DUSE_FFTWD:BOOL=ON"
		CMAKE_VARIABLES="${CMAKE_VARIABLES} -DUSE_FFTWF:BOOL=ON"
	else
		CMAKE_VARIABLES="${CMAKE_VARIABLES} -DUSE_FFTWD:BOOL=OFF"
		CMAKE_VARIABLES="${CMAKE_VARIABLES} -DUSE_FFTWD:BOOL=OFF"
	fi

	if use python; then 
		if use oldpython; then
			die "Use flags include both python and oldpython"
		fi
		ewarn "Warning: numpy will be autodetected, ignoring numpy useflag"
		CMAKE_VARIABLES="${CMAKE_VARIABLES} -DITK_USE_REVIEW:BOOL=ON"
		CMAKE_VARIABLES="${CMAKE_VARIABLES} -DUSE_WRAP_ITK:BOOL=ON"
		CMAKE_VARIABLES="${CMAKE_VARIABLES} -DWRAP_ITK_JAVA:BOOL=OFF"
		CMAKE_VARIABLES="${CMAKE_VARIABLES} -DWRAP_ITK_PYTHON:BOOL=ON"
		CMAKE_VARIABLES="${CMAKE_VARIABLES} -DWRAP_ITK_TCL:BOOL=OFF"
	else
		CMAKE_VARIABLES="${CMAKE_VARIABLES} -DUSE_WRAP_ITK:BOOL=OFF"
	fi 

	if use oldpython; then
		if use numpy; then
			CMAKE_VARIABLES="${CMAKE_VARIABLES} -DITK_USE_PYTHON_NUMARRAY=ON"
		else
			CMAKE_VARIABLES="${CMAKE_VARIABLES} -DITK_USE_PYTHON_NUMARRAY=OFF"
		fi
		ewarn "Warning: python bindings will be installed in a nonstandard path"
 		CMAKE_VARIABLES="${CMAKE_VARIABLES} -DITK_CSWIG_PYTHON:BOOL=ON"
	else
		CMAKE_VARIABLES="${CMAKE_VARIABLES} -DITK_CSWIG_PYTHON:BOOL=OFF"
	fi

	if use examples; then
		CMAKE_VARIABLES="${CMAKE_VARIABLES} -DBUILD_EXAMPLES:BOOL=ON"
	else
		CMAKE_VARIABLES="${CMAKE_VARIABLES} -DBUILD_EXAMPLES:BOOL=OFF"
	fi

	if use patented; then
		CMAKE_VARIABLES="${CMAKE_VARIABLES} -DITK_USE_PATENTED:BOOL=ON"
	else
		CMAKE_VARIABLES="${CMAKE_VARIABLES} -DITK_USE_PATENTED:BOOL=OFF"
	fi

	if use shared; then
		CMAKE_VARIABLES="${CMAKE_VARIABLES} -DBUILD_SHARED_LIBS:BOOL=ON"
	else
		CMAKE_VARIABLES="${CMAKE_VARIABLES} -DBUILD_SHARED_LIBS:BOOL=OFF"
	fi

	if use test; then
		CMAKE_VARIABLES="${CMAKE_VARIABLES} -DBUILD_TESTING:BOOL=ON"
	else
		CMAKE_VARIABLES="${CMAKE_VARIABLES} -DBUILD_TESTING:BOOL=OFF"
	fi

	# Give us an optimised release build
	CMAKE_VARIABLES="${CMAKE_VARIABLES} -DCMAKE_BUILD_TYPE:STRING=RELWITHDEBINFO"

	# Use the system libraries for these
	CMAKE_VARIABLES="${CMAKE_VARIABLES} -DITK_USE_SYSTEM_JPEG:BOOL=ON"
	CMAKE_VARIABLES="${CMAKE_VARIABLES} -DITK_USE_SYSTEM_PNG:BOOL=ON"
	CMAKE_VARIABLES="${CMAKE_VARIABLES} -DITK_USE_SYSTEM_TIFF:BOOL=ON"
	CMAKE_VARIABLES="${CMAKE_VARIABLES} -DITK_USE_SYSTEM_ZLIB:BOOL=ON"


	echo -n "cmake_vars:"
	echo ${CMAKE_VARIABLES}

	# Run CMake twice to configure properly with CMake 2.2.x
	cmake ${CMAKE_VARIABLES} . && cmake ${CMAKE_VARIABLES} . 		\
		|| die "cmake configuration failed"

	#when wrapping with cableswig is enabled, paallel builds break
	if use python; then
	   emake -j1 || die "emake failed"
	else
	   emake || die "emake failed"
	fi
}

src_install() {

	cd "${S}"

	make DESTDIR="${D}" install || die "make install failed"

	# install the documentation
	if use doc; then
		mv README.html README-Overview.html
		dodoc	"${S}"/README-Overview.html

		dodoc	"${S}"/Documentation/DeveloperList.txt			\
				"${S}"/Documentation/InsightDeveloperStart.doc	\
				"${S}"/Documentation/InsightDeveloperStart.pdf	\
				"${S}"/Documentation/README.html				\
				"${S}"/Documentation/Style.pdf					\
				"${S}"/Documentation/itk.ico

		docinto Doxygen
		dodoc	"${S}"/Documentation/Doxygen/*.dox				\
				"${S}"/Documentation/Doxygen/*.html				\
				"${S}"/Documentation/Doxygen/*.css

		docinto Art
		dodoc	"${S}"/Documentation/Art/*gif					\
				"${S}"/Documentation/Art/*jpg					\
				"${S}"/Documentation/Art/*psd					\
				"${S}"/Documentation/Art/*xpm
	fi

	# install the examples
	if use examples; then
		# Copy Example sources
		dodir /usr/share/${MY_PN}/examples ||	\
			die "Failed to create examples directory"
		cp -pPR "${S}/Examples" "${D}/usr/share/${MY_PN}/examples/src" ||	\
			die "Failed to copy example files"

		# copy binary examples
		cp -pPR "${S}/bin" "${D}/usr/share/${MY_PN}/examples" || \
			die "Failed to copy binary example files"
		rm -rf "${D}"/usr/share/"${MY_PN}"/examples/bin/*.so || \
			die "Failed to remove libraries from examples directory"

		# remove CVS directories from examples folder
#		find "${D}"/usr/share/"${MY_PN}"/examples -type d -name CVS -exec	\
#			rm -rf {} \; ||											\
#			die "Failed to remove CVS folders"

		# fix examples permissions
		find "${D}/usr/share/${MY_PN}/examples" -type d -exec	\
			chmod 0755 {} \; ||								\
			die "Failed to fix example directories permissions"
		find "${D}/usr/share/${MY_PN}/examples" -type f -exec	\
			chmod 0644 {} \; ||								\
			die "Failed to fix example files permissions"
	fi

	LDPATH="/usr/lib/InsightToolkit"
	echo "LDPATH=${LDPATH}" > $T/40${PN}
	echo "ITK_DATA_ROOT=/usr/share/${PN}/data" >> ${T}/40${PN}
	doenvd "${T}/40${PN}"

}

pkg_postinst() {

	if use patented; then
		ewarn "Using patented code in ITK may require a license."
		ewarn "For more information, please read:"
		ewarn "http://www.itk.org/HTML/Copyright.htm"
		ewarn "http://www.itk.org/Wiki/ITK_Patent_Bazaar"
	fi

}
