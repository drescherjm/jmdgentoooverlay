EAPI=6

inherit multilib

MY_PV="${PV/_rc/rc}"
MY_P="${PN#nagios-}_v${MY_PV}"

DESCRIPTION="lm_sensors plugin for Nagios"
HOMEPAGE="http://matteocorti.github.io/check_lm_sensors/"
SRC_URI="https://raw.githubusercontent.com/drescherjm/check_lm_sensors/master/check_lm_sensors"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE=""

DEPEND=""
RDEPEND="dev-lang/perl
        dev-perl/Readonly
        dev-perl/List-MoreUtils
	dev-perl/Monitoring-Plugin"

S="${WORKDIR}/${MY_P}"

src_install() {
	exeinto /usr/$(get_libdir)/nagios/plugins
	doexe check_lm_sensors 
}

src_unpack() {
        # The file in the download is the perl text file so we do not do the standard unpack
        mkdir -p "${S}"
	cp "${DISTDIR}/${A}" "${S}"
        sed -i 'sQ#!perlQ#!/usr/bin/perlQg' "${S}/${A}" 
}
