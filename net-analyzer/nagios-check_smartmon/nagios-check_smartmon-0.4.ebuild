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
RDEPEND="dev-lang/perl
         app-admin/sudo"

S="${WORKDIR}/${MY_P}"


src_compile() {
cat - > "${T}"/50${PN} <<EOF
Cmnd_Alias NAGIOS_PLUGINS_JMD_CMDS = /usr/lib/nagios/plugins/check_smartmon
User_Alias NAGIOS_PLUGINS_JMD_USERS = nagios

NAGIOS_PLUGINS_JMD_USERS ALL=(root) NOPASSWD: NAGIOS_PLUGINS_JMD_CMDS
EOF
}

src_install() {
	insinto /etc/sudoers.d
        doins "${T}"/50${PN}

	exeinto /usr/$(get_libdir)/nagios/plugins
	doexe check_smartmon
}

src_unpack() {
        # The file in the download is the perl text file so we do not do the standard unpack
        mkdir -p "${S}"
	cp "${DISTDIR}/${A}" "${S}"

	# BUG Fix the --attr-raw and --attr were not working for more than 1 attribute.
	sed -i -e 's#@ATTRRAW = splice(@ATTRRAW, $idx, 1);##g' -e 's#@ATTR = splice(@ATTR, $idx, 1);##g' "${S}/${A}"
}
