# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

DESCRIPTION="DoxyS Documentation System"
HOMEPAGE="http://www.doxys.dk"
SRC_URI="http://www.doxys.org/download/doxys_084b_src.zip"

LICENSE="GPL"
SLOT="0"
KEYWORDS="~x86"
IUSE=""

RDEPEND="virtual/glibc
	sys-devel/gcc"
	
DEPEND="${RDEPEND}"

S="${WORKDIR}/doxys-084"

src_unpack() {
	unpack ${A}
	
	if use debug; then 
		RESTRICT="nostrip"
	else
		sed -i ${S}/configure.in \
			-e "s:\(DEBUG_CFLAGS=\).*:\1\"${CFLAGS}\":"
	fi
}

src_compile() {
	autoconf || die "autoconf failed"
		
	emake -j1 || die "emake failed"
}

src_install() {
	exeinto ${GAMES_LIBDIR}
	doexe stratagus
	prepgamesdirs
	
	dodoc README
	mv doc/ ${D}/usr/share/doc/${PF}/

	use doc && {
		dohtml srcdoc/html/*
	}
}
