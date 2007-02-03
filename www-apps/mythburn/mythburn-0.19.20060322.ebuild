inherit webapp eutils depend.php

DESCRIPTION="Web based (PHP Script) mythtv dvd creator."
HOMEPAGE="http://sourceforge.net/projects/mythburn"
SRC_URI="${P}.tar.bz2"

LICENSE="GPL-2"
KEYWORDS="~amd64 ~x86"
IUSE=""
RESTRICT="fetch"

RDEPEND="virtual/httpd-php
	dev-php/PEAR-DB
	>=www-apps/mythweb-0.19"

S=${WORKDIR}/${PN}

src_unpack() {
        unpack ${A}

	einfo "Removoving CVS folders - Please ignore any No such file or directory errors"
	#Remove CVS folders
	find ${S} -name CVS -exec rm -Rf {} \;

#	pwd
#	epatch ${FILESDIR}/bacula-web-${PV}-cvs_updates.patch
#	epatch ${FILESDIR}/bacula-web-${PV}-nulldate.patch
#	epatch ${FILESDIR}/bacula-web-${PV}-dbsize.patch
}

pkg_setup() {

	webapp_pkg_setup

	if has_version 'dev-lang/php' ; then
		require_php_with_use session
	fi

	einfo ${MY_HTDOCSDIR}
}

src_compile(){
	pwd
}

src_install() {
        webapp_src_preinst

	pwd

	einfo ${MY_HTDOCSDIR}

	#die

        cp -R ${S}/* ${D}/${MY_HTDOCSDIR}

	chdir  ${D}/${MY_HTDOCSDIR}
	die

#	webapp_configfile ${MY_HTDOCSDIR}/configs/bacula.conf
	webapp_serverowned -R ${MY_HTDOCSDIR}/mythweb
        webapp_src_install

	dosym ../../${PN} ${ROOT}${VHOST_ROOT}/${MY_HTDOCSBASE}/mythweb/modules

}

