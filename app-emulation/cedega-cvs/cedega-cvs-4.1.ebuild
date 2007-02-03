# Copyright 1999-2003 Gentoo Technologies, Inc.
# Distributed under the terms of the GNU General Public License v2
# $Header: $

IUSE="cups opengl nptl"

inherit eutils flag-o-matic

strip-flags

inherit cvs
ECVS_SERVER="cvs.transgaming.org:/cvsroot"
ECVS_MODULE="winex"
ECVS_BRANCH="HEAD"
ECVS_PASS="cvs"
ECVS_USER="cvs"


S=${WORKDIR}/${ECVS_MODULE}
	
DESCRIPTION="Cedega is a distribution of Wine with enhanced DirectX for gaming.
	     This ebuild will fetch the newest cvs sources from the cvs-server."
HOMEPAGE="http://www.transgaming.com/"

SLOT="0"
KEYWORDS="x86 -ppc"
LICENSE="Aladdin"

DEPEND="sys-devel/gcc
	sys-devel/flex
	dev-util/yacc
	>=media-libs/freetype-2.0.0
	X? ( 	virtual/x11 
		dev-lang/tcl 
		dev-lang/tk ) 
	opengl? ( virtual/opengl )
	cups? ( net-print/cups )"

pkg_setup () {
	VOID=`cat /etc/env.d/09opengl | grep xfree`
}

src_unpack() {
	cvs_src_unpack
}

src_compile() {
	cd ${S}
	local myconf

	use opengl && myconf="--enable-opengl" || myconf="--disable-opengl"
	[ -z $DEBUG ] && myconf="$myconf --disable-trace --disable-debug" || myconf="$myconf --enable-trace --enable-debug"

	# for nptl threads
	use nptl && myconf="$myconf --enable-pthreads"

	# patching cedega to not compile wcmd
	epatch ${FILESDIR}/cedega-cvs-makefile.patch

	./configure --prefix=/usr/ \
		--sysconfdir=/etc/cedega-cvs \
		--host=${CHOST} \
		--enable-curses \
		--with-x \
		--enable-freetype \
		${myconf} || die "configure failed"

	# Fixes a winetest issue
	cd ${S}/programs/winetest
	cp Makefile 1
	sed -e 's:wine.pm:include/wine.pm:' 1 > Makefile

	# This persuades wineshelllink that "cedega-cvs" is a better loader :)
	cd ${S}/tools
	cp wineshelllink 1
	sed -e 's/\(WINE_LOADER=\)\(\${WINE_LOADER:-wine}\)/\1cedega-cvs/' 1 > wineshelllink

	cd ${S}	
	make depend all || die "make depend all failed"
	cd programs && gmake || die "emake died"
}

src_install () {
	local WINEXMAKEOPTS="prefix=${D}/usr/lib/cedega-cvs"
	
	# Installs cedega to /usr/lib/cedega-cvs
	cd ${S}
	make ${WINEXMAKEOPTS} install || die "make install failed"
	cd ${S}/programs
	make ${WINEXMAKEOPTS} install || die "make install failed"
	

	# Creates /usr/lib/cedega-cvs/.data with fake_windows in it
	# This is needed for our new cedega-cvs wrapper script
	dodir /usr/lib/cedega-cvs/.data
	pushd ${D}/usr/lib/cedega-cvs/.data
	tar jxvf ${FILESDIR}/${PN}-fake_windows.tar.bz2 
	popd
	cp ${S}/documentation/samples/config ${S}/documentation/samples/config.orig
	sed -e 's/.transgaming\/c_drive/.cedega-cvs\/fake_windows/' \
	    ${S}/documentation/samples/config.orig > ${S}/documentation/samples/config
	cp ${S}/documentation/samples/config ${D}/usr/lib/cedega-cvs/.data/config
	cp ${WORKDIR}/wine/winedefault.reg ${D}/usr/lib/cedega-cvs/.data/winedefault.reg
	# Install the wrapper script
	dodir /usr/bin
	cp ${FILESDIR}/${PN}-cedega ${D}/usr/bin/cedega-cvs
	cp ${FILESDIR}/${PN}-regedit ${D}/usr/bin/regedit-cedega-cvs

	# Take care of the other stuff
	cd ${S}
	dodoc ANNOUNCE AUTHORS BUGS ChangeLog DEVELOPERS-HINTS LICENSE README

	insinto /usr/lib/cedega-cvs/.data/fake_windows/Windows
	doins documentation/samples/system.ini
	doins documentation/samples/generic.ppd
	
	# Manpage setup
	cp ${D}/usr/lib/${PN}/man/man1/wine.1 ${D}/usr/lib/${PN}/man/man1/${PN}.1
	doman ${D}/usr/lib/${PN}/man/man1/${PN}.1
	rm ${D}/usr/lib/${PN}/man/man1/${PN}.1
	doman ${D}/usr/lib/${PN}/man/man5/wine.conf.5
	rm ${D}/usr/lib/${PN}/man/man5/wine.conf.5

	# Remove the executable flag from those libraries.
	cd ${D}/usr/bin
	chmod a+x ./cedega-cvs
	chmod a-x *.so
		
}

pkg_postinst() {
	einfo "Use /usr/bin/cedega-cvs to start cedega."
	einfo "This is a wrapper-script which will take care of everything"
	einfo "else. If you have further questions, enhancements or patches"
	einfo "send an email to phoenix@gentoo.org"
	einfo ""
	einfo "Manpage has been installed to the system."
	einfo "\"man cedega-cvs\" should show it."
}


