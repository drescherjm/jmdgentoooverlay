<<<<<<< Updated upstream
<<<<<<< Updated upstream
EAPI=8
=======
EAPI=7
>>>>>>> Stashed changes
=======
EAPI=7
>>>>>>> Stashed changes

inherit multilib

MY_PV="${PV/_rc/rc}"
MY_P="${PN#nagios-}_v${MY_PV}"

DESCRIPTION="nagios plugin to check mdadm status"
HOMEPAGE="https://github.com/Napsty/check_zpools"
SRC_URI=""

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE=""

DEPEND=""
RDEPEND="app-admin/sudo"

S="${WORKDIR}/${MY_P}"

src_install() {
	#insinto /etc/sudoers.d
        #doins "${T}"/50${PN}
	exeinto /usr/$(get_libdir)/nagios/plugins
	doexe check_zpools.sh
}

src_unpack() {
        # The file in the download is the perl text file so we do not do the standard unpack
        mkdir -p "${S}"
	cp "${FILESDIR}/check_zpools.sh" "${S}"
        cd "${S}"
}
