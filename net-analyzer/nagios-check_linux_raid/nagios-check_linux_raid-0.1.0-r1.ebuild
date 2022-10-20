EAPI=6

inherit multilib eutils

MY_PV="${PV/_rc/rc}"
MY_P="${PN#nagios-}_v${MY_PV}"

DESCRIPTION="nagios plugin to check mdadm status"
HOMEPAGE=""
SRC_URI=""

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE=""

DEPEND=""
RDEPEND="dev-lang/perl
         app-admin/sudo"

S="${WORKDIR}/${MY_P}"

#src_compile() {
#cat - > "${T}"/50${PN} <<EOF
#Cmnd_Alias NAGIOS_PLUGINS_CHECK_SAMBA_CMDS = /usr/lib/nagios/plugins/check_wbinfo
#User_Alias NAGIOS_PLUGINS_CHECK_SAMBA_USERS = nagios
#
#NAGIOS_PLUGINS_CHECK_ZFS_USERS ALL=(root) NOPASSWD: NAGIOS_PLUGINS_CHECK_SAMBA_CMDS
#EOF
#}

src_install() {
	#insinto /etc/sudoers.d
        #doins "${T}"/50${PN}
	exeinto /usr/$(get_libdir)/nagios/plugins
	doexe check_linux_raid.pl
}

src_unpack() {
        # The file in the download is the perl text file so we do not do the standard unpack
        mkdir -p "${S}"
	cp "${FILESDIR}/check_linux_raid.pl" "${S}"
        cd "${S}"
}
