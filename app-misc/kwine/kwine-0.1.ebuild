# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils

DESCRIPTION="A set of tools for wine and kde interoperability"
HOMEPAGE="http://kwine.sourceforge.net/"
SRC_URI="mirror://sourceforge/${PN}/kfile_wine-${PV}.tar.gz
	mirror://sourceforge/${PN}/kio_wine-${PV}.tar.gz
	mirror://sourceforge/${PN}/kwine-${PV}.tar.gz
	mirror://sourceforge/${PN}/kwine_startmenu-${PV}.tar.gz"
LICENSE="GPL"

SLOT="0"
KEYWORDS="~x86"
IUSE="arts"
RESTRICT="nomirror"
DEPEND="app-emulation/wine
	>=app-misc/kwinedeps-${PV}"
# Run-time dependencies, same as DEPEND if RDEPEND isn't defined:
#RDEPEND=""

src_compile() {
# config
	for pkg in $(ls ${WORKDIR}); do
		S=${WORKDIR}/${pkg}
		cd $S || die

		# Make sure the compiler can find the wine headers
		# ln -s /usr/include/wine/windows/* src || die

        	econf --prefix=`kde-config --prefix` \
			--with-extra-includes=/usr/include/wine/windows \
			$(use_with arts) || die "econf failed"
	done

# make
	for pkg in $(ls ${WORKDIR}); do
		S=${WORKDIR}/${pkg}
		cd $S || die
		emake || die "emake failed"
	done
}

src_install() {
# install
	for pkg in $(ls ${WORKDIR}); do
		S=${WORKDIR}/${pkg}
		cd $S
        	emake DESTDIR="${D}" install || die "emake install failed"
	done
}

