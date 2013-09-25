EAPI=5

inherit multilib

MY_PV="${PV/_rc/rc}"
MY_P="${PN#nagios-}_v${MY_PV}"

DESCRIPTION="nagios plugin to check smartctl output"
HOMEPAGE="http://lancet.mit.edu/mwall/projects/nagios/plugins.html"
SRC_URI="http://lancet.mit.edu/mwall/projects/nagios/check_smartmon"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE=""

DEPEND=""
RDEPEND="dev-lang/perl"

S="${WORKDIR}/${MY_P}"

src_install() {
	exeinto /usr/$(get_libdir)/nagios/plugins
	doexe check_smartmon
}

src_unpack() {
        # The file in the download is the perl text file so we do not do the standard unpack
        mkdir -p "${S}"
	cp "${DISTDIR}/${A}" "${S}"
}
