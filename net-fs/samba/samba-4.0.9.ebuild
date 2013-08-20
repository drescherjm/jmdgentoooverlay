# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-fs/samba/samba-4.0.8-r2.ebuild,v 1.1 2013/08/16 07:13:48 polynomial-c Exp $

EAPI=5
PYTHON_COMPAT=( python2_{5,6,7} )

inherit python-r1 waf-utils multilib linux-info systemd

MY_PV="${PV/_rc/rc}"
MY_P="${PN}-${MY_PV}"

if [ "${PV}" = "4.9999" ]; then
	EGIT_REPO_URI="git://git.samba.org/samba.git"
	KEYWORDS=""
	inherit git-2
else
	SRC_URI="mirror://samba/stable/${MY_P}.tar.gz"
	KEYWORDS="~amd64 ~hppa ~x86"
fi

DESCRIPTION="Samba Suite Version 4"
HOMEPAGE="http://www.samba.org/"
LICENSE="GPL-3"

SLOT="0"

IUSE="acl addns ads aio avahi client cluster cups gnutls iprint
ldap pam quota selinux swat syslog test winbind"

RDEPEND="${PYTHON_DEPS}
	dev-libs/iniparser
	dev-libs/popt
	sys-libs/readline
	virtual/libiconv
	dev-python/subunit
	sys-libs/libcap
	>=sys-libs/ldb-1.1.16
	>=sys-libs/tdb-1.2.11[python]
	>=sys-libs/talloc-2.0.8[python]
	>=sys-libs/tevent-0.9.18
	sys-libs/zlib
	>=app-crypt/heimdal-1.5[-ssl]
	addns? ( net-dns/bind-tools[gssapi] )
	client? ( net-fs/cifs-utils[ads?] )
	cluster? ( >=dev-db/ctdb-1.0.114_p1 )
	ldap? ( net-nds/openldap )
	gnutls? ( >=net-libs/gnutls-1.4.0 )
	selinux? ( sec-policy/selinux-samba )"
DEPEND="${RDEPEND}
	virtual/pkgconfig"

REQUIRED_USE="ads? ( ldap )"

RESTRICT="mirror"

S="${WORKDIR}/${MY_P}"

CONFDIR="${FILESDIR}/$(get_version_component_range 1-2)"

WAF_BINARY="${S}/buildtools/bin/waf"

pkg_setup() {
	python_export_best
	if use aio; then
		if ! linux_config_exists || ! linux_chkconfig_present AIO; then
				ewarn "You must enable AIO support in your kernel config, "
				ewarn "to be able to support asynchronous I/O. "
				ewarn "You can find it at"
				ewarn
				ewarn "General Support"
				ewarn " Enable AIO support "
				ewarn
				ewarn "and recompile your kernel..."
		fi
	fi
}

src_configure() {
	local myconf=''
	use "cluster" && myconf+=" --with-ctdb-dir=/usr"
	use "test" && myconf+=" --enable-selftest"
	myconf="${myconf} \
		--enable-fhs \
		--sysconfdir=/etc \
		--localstatedir=/var \
		--with-modulesdir=/usr/$(get_libdir)/samba \
		--with-pammodulesdir=/$(get_libdir)/security \
		--disable-rpath \
		--disable-rpath-install \
		--nopyc \
		--nopyo \
		--disable-ntdb \
		--bundled-libraries=NONE \
		--builtin-libraries=NONE \
		$(use_with addns dnsupdate) \
		$(use_with acl) \
		$(use_with ads) \
		$(use_with aio aio-support) \
		$(use_enable avahi) \
		$(use_with cluster cluster-support) \
		$(use_enable cups) \
		$(use_enable gnutls) \
		$(use_enable iprint) \
		$(use_with ldap) \
		$(use_with pam) \
		$(use_with pam pam_smbpass) \
		$(use_with quota) \
		$(use_with syslog) \
		$(use_with swat) \
		$(use_with winbind)
		"
	use "ads" && myconf+=" --with-shared-modules=idmap_ad"

	CPPFLAGS="-I/usr/include/et ${CPPFLAGS}" \
		waf-utils_src_configure ${myconf}
}

src_install() {
	waf-utils_src_install

	# Seems like the build script gets the shebangs correct by itself
	# (4.0.6)
	#python_replicate_script \
	#	"${D}/usr/sbin/samba_dnsupdate" \
	#	"${D}/usr/sbin/samba_spnupdate" \
	#	"${D}/usr/sbin/samba_upgradedns" \
	#	"${D}/usr/sbin/samba_kcc" \
	#	"${D}/usr/bin/samba-tool"

	# Make all .so files executable
	find "${D}" -type f -name "*.so" -exec chmod +x {} +

	# Install init script and conf.d file
	newinitd "${CONFDIR}/samba4.initd-r1" samba
	newconfd "${CONFDIR}/samba4.confd" samba

	systemd_dotmpfilesd "${FILESDIR}"/samba.conf
	systemd_dounit "${FILESDIR}"/nmbd.service
	systemd_dounit "${FILESDIR}"/smbd.{service,socket}
	systemd_newunit "${FILESDIR}"/smbd_at.service 'smbd@.service'
	systemd_dounit "${FILESDIR}"/winbindd.service
}

src_test() {
	"${WAF_BINARY}" test || die "test failed"
}

pkg_postinst() {
	elog "This is is the first stable release of Samba 4.0"

	ewarn "Be aware the this release contains the best of all of Samba's"
	ewarn "technology parts, both a file server (that you can reasonably expect"
	ewarn "to upgrade existing Samba 3.x releases to) and the AD domain"
	ewarn "controller work previously known as 'samba4'."

	elog "For further information and migration steps make sure to read "
	elog "http://samba.org/samba/history/${P}.html "
	elog "http://samba.org/samba/history/${PN}-4.0.0.html and"
	elog "http://wiki.samba.org/index.php/Samba4/HOWTO "
}
