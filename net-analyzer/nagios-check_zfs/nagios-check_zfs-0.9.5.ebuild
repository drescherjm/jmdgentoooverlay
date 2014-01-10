EAPI=5

inherit multilib

MY_PV="${PV/_rc/rc}"
MY_P="${PN#nagios-}_v${MY_PV}"

DESCRIPTION="nagios plugin to check zfs status"
HOMEPAGE="http://exchange.nagios.org/directory/Plugins/Operating-Systems/Solaris/check_zfs/details"
SRC_URI="http://karlsbakk.net/nagios/check_zfs"

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
Cmnd_Alias NAGIOS_PLUGINS_JMD_CMDS = /usr/lib/nagios/plugins/check_zfs
User_Alias NAGIOS_PLUGINS_JMD_USERS = nagios

NAGIOS_PLUGINS_JMD_USERS ALL=(root) NOPASSWD: NAGIOS_PLUGINS_JMD_CMDS
EOF

cat - > "${T}"/91-zfs-permissions.rules <<EOF
# Use this to add a group and more permissive permissions for zfs
# so that you don't always need run it as root.  beware, users not root
# can do nearly EVERYTHING, including, but not limited to destroying
# volumes and deleting datasets.  they CANNOT mount datasets or create new
# volumes, export datasets via NFS, or other things that require root
# permissions outside of ZFS.
ACTION=="add", KERNEL=="zfs", MODE="0660", GROUP="disk"
EOF
}

src_install() {
	insinto /etc/sudoers.d
        doins "${T}"/50${PN}

	insinto /etc/udev/rules.d
        doins "${T}"/91-zfs-permissions.rules

        sed -i 's#/usr/sbin/zpool#/sbin/zpool#g' check_zfs

	exeinto /usr/$(get_libdir)/nagios/plugins
	doexe check_zfs

	einfo "For sudo to work make sure you have the following in your sudoers file #includedir /etc/sudoers.d"
}

src_unpack() {
        # The file in the download is the perl text file so we do not do the standard unpack
        mkdir -p "${S}"
	cp "${DISTDIR}/${A}" "${S}"
}
