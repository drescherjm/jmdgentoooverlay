# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/jpeg-mmx/jpeg-mmx-0.1.6-r1.ebuild,v 1.5 2006/03/15 06:30:02 halcy0n Exp $

inherit eutils flag-o-matic

DESCRIPTION="JPEG library with mmx enhancements"
HOMEPAGE="http://mjpeg.sourceforge.net/"
SRC_URI="mirror://sourceforge/mjpeg/${P}.tar.gz"

LICENSE="as-is"
SLOT="0"
KEYWORDS="-* x86"
IUSE=""

DEPEND="dev-lang/nasm"
RDEPEND=""

S=${WORKDIR}/jpeg-mmx

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${P}-PIC.patch
	epatch "${FILESDIR}"/${P}-makefile.patch
	epatch "${FILESDIR}"/${P}-gcc41.patch
}

src_compile() {
	# filter -fforce-addr because it breaks compile
	filter-flags -fforce-addr
	# -fomit-frame-pointer causes a segfault in djpeg-mmx (Bug #114103)
	filter-flags -fomit-frame-pointer

	econf \
		--includedir=/usr/include/jpeg-mmx \
		--enable-shared \
		--enable-static \
		|| die "configure failed"
	emake || die "make failed"
}

src_install() {
	dodir /usr/include/jpeg-mmx
	make install-headers includedir="${D}"/usr/include/jpeg-mmx || die "headers"

	for x in cjpeg djpeg jpegtran ; do
		newbin .libs/${x} ${x}-mmx || die "dobin ${x}"
	done

	dolib.a .libs/libjpeg-mmx.a || die "dolib.a"
	cp -pPR .libs/libjpeg-mmx.so* libjpeg-mmx.la "${D}"/usr/lib/ || die "dolib.so"

	dodoc README change.log structure.doc libjpeg.doc
}
