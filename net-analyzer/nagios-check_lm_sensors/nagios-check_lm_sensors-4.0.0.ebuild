EAPI=5

inherit multilib

MY_PV="${PV/_rc/rc}"
MY_P="${PN#nagios-}_v${MY_PV}"

DESCRIPTION="lm_sensors plugin for Nagios"
HOMEPAGE="https://svn.id.ethz.ch/nagios_plugins/check_lm_sensors"
SRC_URI="https://svn.id.ethz.ch/nagios_plugins/check_lm_sensors/check_lm_sensors"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE=""

DEPEND=""
RDEPEND="dev-lang/perl
        dev-perl/Readonly
        dev-perl/List-MoreUtils
	dev-perl/Nagios-Plugin"

S="${WORKDIR}/${MY_P}"

src_install() {
	exeinto /usr/$(get_libdir)/nagios/plugins
	doexe check_lm_sensors 
}

src_unpack() {
        # The file in the download is the perl text file so we do not do the standard upack
        mkdir -p "${S}"
	cp "${DISTDIR}/${A}" "${S}"
        sed -i 'sQ#!perlQ#!/usr/bin/perlQg' "${S}/${A}" 
}
