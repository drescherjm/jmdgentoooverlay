# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/www-apps/mythweb/mythweb-0.21_p17573.ebuild,v 1.4 2008/12/23 17:28:26 maekke Exp $

ESVN_PROJECT="mythplugins"

inherit mythtv webapp depend.php subversion

DESCRIPTION="PHP scripts intended to manage MythTV from a web browser."
IUSE=""
KEYWORDS="amd64 ppc x86"

RDEPEND="dev-perl/DBI
	dev-perl/DBD-mysql"

need_httpd_cgi
need_php5_httpd

pkg_setup() {
	webapp_pkg_setup
	require_php_with_use session mysql pcre posix
}

src_unpack() {
	subversion_src_unpack
}

src_compile() {
	:
}

src_install() {
	webapp_src_preinst

	cd "${S}"/mythweb
	dodoc README INSTALL

	dodir "${MY_HTDOCSDIR}"/data

	insinto "${MY_HTDOCSDIR}"
	doins -r [[:lower:]]*

	webapp_configfile "${MY_HTDOCSDIR}"/mythweb.conf.{apache,lighttpd}

	webapp_serverowned "${MY_HTDOCSDIR}"/data

	webapp_postinst_txt en "${FILESDIR}"/postinstall-en-0.21.txt

	webapp_src_install
}
