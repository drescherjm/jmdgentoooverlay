inherit webapp  eutils

DESCRIPTION="Web based (PHP Script) bacula status viewer."
HOMEPAGE="http://www.bacula.org/"
SRC_URI="mirror://sourceforge/bacula/bacula-gui-${PV}.tar.gz"

LICENSE="GPL-2"
KEYWORDS="~amd64 ~x86"
IUSE="mysql postgres"

RDEPEND="virtual/httpd-php
	dev-php/PEAR-DB
        dev-php/smarty
        app-backup/bacula"
#	>=app-backup/bacula-${PV}"

S=${WORKDIR}/bacula-gui-${PV}/bacula-web

src_unpack() {
        unpack ${A}
	cd ${S}
	pwd
	epatch ${FILESDIR}/bacula-web-${PV}-nulldate.patch
	epatch ${FILESDIR}/bacula-web-${PV}-dbsize.patch

	if use postgres; then
		if has_version 'dev-lang/php' ; then
                	require_php_with_use postgres
        	fi
	fi


	if use mysql; then
                if has_version 'dev-lang/php' ; then
                        require_php_with_use mysqli
                fi
        fi

}

src_compile(){
	pwd
}

src_install() {
        webapp_src_preinst

        cp -R * ${D}/${MY_HTDOCSDIR}
	webapp_configfile ${MY_HTDOCSDIR}/configs/bacula.conf
	webapp_serverowned -R ${MY_HTDOCSDIR}
        webapp_src_install
}

