# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils

DESCRIPTION="dependency of kwine"
HOMEPAGE="http://kwine.sourceforge.net/"
SRC_URI="mirror://sourceforge/kwine/kwinetools-${PV}.tar.gz
	mirror://sourceforge/kwine/kwinedcop-${PV}.tar.gz"
LICENSE="GPL"

SLOT="0"
KEYWORDS="~x86"
IUSE="arts"
RESTRICT="nomirror"
DEPEND="app-emulation/wine"
# Run-time dependencies, same as DEPEND if RDEPEND isn't defined:
#RDEPEND=""

src_compile() {
	for pkg in $(ls ${WORKDIR}); do
		S=${WORKDIR}/${pkg}
		cd $S || die
		econf --prefix=`kde-config --prefix` \
			--with-extra-includes=/usr/include/wine/windows \
			 $(use_with arts) || die "econf failed"
	done

	for pkg in $(ls ${WORKDIR}); do
		S=${WORKDIR}/${pkg}
		cd $S || die
		emake || die "emake failed"
	done
}

src_install() {
	for pkg in $(ls ${WORKDIR}); do
		S=${WORKDIR}/${pkg}
		cd $S || die
		emake DESTDIR="${D}" install || die "emake install failed"
	done
}

