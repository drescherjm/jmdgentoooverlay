EAPI=2
inherit webapp depend.php eutils

MY_PV=${PV/_beta/-b}
MY_P=bacula-${MY_PV}


DESCRIPTION="Web based (PHP Script) bacula tool"
HOMEPAGE="http://www.bacula.org"
SRC_URI="mirror://sourceforge/bacula/bacula-gui-${MY_PV}.tar.gz"


LICENSE="GPL-2"
KEYWORDS="~amd64 ~x86"
IUSE="mysql postgres"


RDEPEND="virtual/httpd-php
        dev-php/PEAR-DB
	postgres? ( dev-lang/php[postgres,gd,apache2,truetype,cli,xml,zlib,pdo] )
	mysql? ( dev-lang/php[mysql,gd,apache2,truetype,cli,xml,zlib,pdo] )
	>=app-backup/bacula-7.0.2"

S=${WORKDIR}

src_install() {
        webapp_src_preinst

        cp -R * ${D}/${MY_HTDOCSDIR}
	#webapp_configfile ${MY_HTDOCSDIR}/configs/bacula.conf
	webapp_serverowned -R ${MY_HTDOCSDIR}
        webapp_src_install
}

