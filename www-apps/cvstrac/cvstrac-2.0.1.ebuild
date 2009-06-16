# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils webapp

DESCRIPTION="A web-based bug and patch-set tracking system for CVS."
HOMEPAGE="http://www.cvstrac.org/"
SRC_URI="http://www.cvstrac.org/${P}.tar.gz"
LICENSE="GPL-2"
#KEYWORDS="x86 ~ppc ~sparc ~amd64"
KEYWORDS=""
IUSE="vhosts"
DEPEND="app-text/rcs
	dev-util/cvs
	=dev-db/sqlite-2.8*"

DOCS="COMPILING COPYING VERSION"

src_unpack() {
	unpack ${A}
	mkdir ${S}/obj
	ln -s ${S}/linux-gcc.mk ${S}/obj/Makefile
	sed -i -e "s#/home/drh/cvstrac/cvstrac#${S}#" ${S}/obj/Makefile
}

src_compile() {
	cd ${S}/obj
	make || die "emake failed"
}

src_install() {
	dobin obj/${PN}

	webapp_src_preinst
	dodoc ${DOCS}
	dohtml howitworks.html

	echo "#!/bin/sh" > ${D}/${MY_CGIBINDIR}/cvstrac.cgi || die
	echo "cvstrac cgi /var/lib/cvstrac" >> ${D}/${MY_CGIBINDIR}/cvstrac.cgi || die
	chmod +x ${D}/${MY_CGIBINDIR}/cvstrac.cgi

	insinto ${MY_HTDOCSDIR}
	doins *.gif obj/index.html

	keepdir /var/lib/cvstrac

	webapp_serverowned ${MY_HTDOCSDIR}
	webapp_src_install
}

pkg_postinst() {
	einfo "To initialize a new CVSTrac database, type the following command"
	einfo "(must be a user other than root to initialize):"
	einfo ""
	einfo "    cvstrac init /var/lib/cvstrac demo"
	einfo ""
	einfo "Open a browser and point to http://host/cvstrac.cgi/demo/"
	einfo "with user setup and password setup to continue."
	einfo ""
	einfo "Please visit the CVSTrac install guide for further details:"
	einfo "http://www.cvstrac.org/cvstrac/wiki?p=CvstracInstallation"
}
