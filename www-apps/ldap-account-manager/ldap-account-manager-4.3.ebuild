# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header:

EAPI="8"

inherit webapp 

DESCRIPTION="PHP based tool for managing various account types (Unix, Samba, Kolab, ...) in an LDAP directory."
HOMEPAGE="http://lam.sf.net"
SRC_URI="mirror://sourceforge/lam/${P}.tar.bz2"
LICENSE="GPL"
KEYWORDS="~amd64 ~ppc ~x86"

IUSE=""

DEPEND="dev-lang/php"
RDEPEND="www-servers/apache"

pkg_setup() {
        #has_php
        webapp_pkg_setup

	# Make sure php was built with the necessary USE flags.
	require_php_with_use ldap xml mhash zip
}

#src_compile() {
#        has_php
#}

# Webserver user and group, here for Apache by default
HTTPD_USER="${HTTPD_USER:-apache}"
HTTPD_GROUP="${HTTPD_GROUP:-apache}"

src_install() {
	webapp_src_preinst

	#dodoc docs/*.txt
	#dodoc INSTALL README TODO HISTORY COPYING
	#dohtml -r doc/devel

	insinto ${MY_HTDOCSDIR}

	doins VERSION
	doins -r config
	doins -r graphics
	doins -r locale
	doins -r tmp
	doins -r sess
	doins -r lib
	doins -r help
	doins -r style
	doins -r templates

	doins index.html

	webapp_serverowned -R ${MY_HTDOCSDIR}/tmp

	webapp_src_install


	#fowners ${HTTPD_USER}:${HTTPD_GROUP} tmp
	#ls -ald tmp

}

pkg_postinst() {
	webapp_pkg_postinst
}
