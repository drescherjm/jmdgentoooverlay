# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit subversion webapp

DESCRIPTION="PHP scripts intended to manage MythTV from a web browser."
ESVN_REPO_URI="http://cvs.mythtv.org/svn/trunk/mythplugins"
ESVN_PROJECT=mythplugins
ESVN_STORE_DIR="${DISTDIR}/svn-src"
_MODULE=${PN/-svn/}
S="${WORKDIR}/${_MODULE}"
HOMEPAGE="http://www.mythtv.org/"
IUSE=""
LICENSE="GPL-2"
KEYWORDS="~x86 ~amd64"

#RDEPEND=">=dev-php/mod_php-4.2

RDEPEND="|| (>=dev-lang/php-4.2 >=dev-php/mod_php-4.2)
	!www-apps/mythweb
	!www-apps/mythweb-cvs"


pkg_setup() {
	webapp_pkg_setup

#	if has_version \>=dev-php/mod_php-5 ; then
#		local modphp_use="$(</var/db/pkg/`best_version =dev-php/mod_php`/USE)"
#	        if ! has session ${modphp_use} ; then
#	                eerror "mod_php is missing session support. Please add"
#	                eerror "'session' to your USE flags, and re-emerge mod_php and php."
#	                die "mod_php needs session support"
#	        fi
#	fi

}

src_compile() {
	return 0
}

src_install() {
	webapp_src_preinst

	dodoc README TODO

	rm -rf /var/tmp/mythweb
	mv ${S}/mythweb /var/tmp
	rm -rf ${S}/*
	mv /var/tmp/mythweb/* ${S}
	mv /var/tmp/mythweb/.htaccess ${S}

	keepdir ${MY_HTDOCSDIR}/video_dir
	keepdir ${MY_HTDOCSDIR}/image_cache
	keepdir ${MY_HTDOCSDIR}/php_sessions

	cp -R [[:lower:]]* .htaccess ${D}${MY_HTDOCSDIR}

	webapp_serverowned ${MY_HTDOCSDIR}/video_dir
	webapp_serverowned ${MY_HTDOCSDIR}/image_cache
	webapp_serverowned ${MY_HTDOCSDIR}/php_sessions

	webapp_configfile ${MY_HTDOCSDIR}/config/conf.php
	webapp_postinst_txt en ${FILESDIR}/postinstall-en.txt

	webapp_src_install
}
