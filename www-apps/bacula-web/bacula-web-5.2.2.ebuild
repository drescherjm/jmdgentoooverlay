EAPI=2
inherit webapp depend.php eutils

DESCRIPTION="Web based (PHP Script) bacula status viewer."
HOMEPAGE="http://www.bacula-web.org"
SRC_URI="http://www.bacula-web.org/tl_files/downloads/bacula-web.5.2.2.tar.gz"

LICENSE="GPL-2"
KEYWORDS="~amd64 ~x86"
IUSE="mysql postgres"


#RDEPEND="virtual/httpd-php
#	#dev-php/PEAR-DB
#        #dev-php/smarty
#        #app-backup/bacula
#	>=app-backup/bacula-5.2.0"


RDEPEND="virtual/httpd-php
	postgres? ( dev-lang/php[postgres,gd,apache2,truetype,cli,xml,zlib,pdo] )
	mysql? ( dev-lang/php[mysql,gd,apache2,truetype,cli,xml,zlib,pdo] )
	>=app-backup/bacula-5.2.0"

S=${WORKDIR}

src_unpack() {
        unpack ${A}
	cd ${S}
	pwd

	#if use postgres; then
	#	if has_version 'dev-lang/php' ; then
        #        	require_php_with_use postgres gd apache2 truetype cli xml zlib pdo
        #	fi
	#fi


	#if use mysql; then
        #        if has_version 'dev-lang/php' ; then
        #                require_php_with_use mysqli
        #        fi
        #fi

}

src_install() {
        webapp_src_preinst

        cp -R * ${D}/${MY_HTDOCSDIR}
	#webapp_configfile ${MY_HTDOCSDIR}/configs/bacula.conf
	webapp_serverowned -R ${MY_HTDOCSDIR}
        webapp_src_install
}

