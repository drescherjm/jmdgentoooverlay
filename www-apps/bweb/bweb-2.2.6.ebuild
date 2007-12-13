inherit webapp perl-module

MY_PV="${PV}-1"

DESCRIPTION="Web based (PHP Script) bacula status viewer."
HOMEPAGE="http://www.bacula.org/"
SRC_URI="mirror://sourceforge/bacula/bacula-gui-${MY_PV}.tar.gz"


LICENSE="GPL-2"
KEYWORDS="~amd64 ~x86"
IUSE="mysql postgres"

RDEPEND="dev-perl/GDGraph
	dev-perl/HTML-Template
	dev-perl/Expect
	dev-perl/Time-modules
        app-backup/bacula"

S=${WORKDIR}/bacula-gui-${MY_PV}/bweb

src_unpack() {
        unpack ${A}
	cd ${S}
}

pkg_setup () {
  webapp_pkg_setup
}

src_install() {

        webapp_src_preinst

        cp -R * ${D}/${MY_HTDOCSDIR}

	webapp_serverowned -R ${MY_HTDOCSDIR}
        webapp_src_install
}

pkg_postinst() {
  webapp_pkg_postinst
}
