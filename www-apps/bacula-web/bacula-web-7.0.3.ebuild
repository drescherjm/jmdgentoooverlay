EAPI=6
inherit webapp eutils

DESCRIPTION="Web based (PHP Script) bacula status viewer."
HOMEPAGE="http://www.bacula-web.org"
SRC_URI="http://www.bacula-web.org/download.html?file=files/bacula-web.org/downloads/${P}.tgz"

LICENSE="GPL-2"
KEYWORDS="~amd64 ~x86"
IUSE="mysql postgres"


#RDEPEND="virtual/httpd-php
#	#dev-php/PEAR-DB
#        #dev-php/smarty
#        #app-backup/bacula
#	>=app-backup/bacula-5.2.0"


RDEPEND="virtual/httpd-php
        dev-php/PEAR-DB
	postgres? ( dev-lang/php[postgres,gd,apache2,truetype,cli,xml,zlib,pdo] )
	mysql? ( dev-lang/php[mysql,gd,apache2,truetype,cli,xml,zlib,pdo] )
	>=app-backup/bacula-5.2.0"

S=${WORKDIR}

src_install() {
        webapp_src_preinst

        cp -R * ${D}/${MY_HTDOCSDIR}
	#webapp_configfile ${MY_HTDOCSDIR}/configs/bacula.conf
	webapp_serverowned -R ${MY_HTDOCSDIR}
        webapp_src_install
}

