# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-admin/webmin/webmin-1.500.ebuild,v 1.1 2009/12/09 14:51:49 patrick Exp $

inherit eutils pam

DESCRIPTION="Webmin, a web-based system administration interface"
HOMEPAGE="http://www.webmin.com/"
SRC_URI="minimal? ( mirror://sourceforge/webadmin/${P}-minimal.tar.gz )
	!minimal? ( mirror://sourceforge/webadmin/${P}.tar.gz )"

LICENSE="BSD"
SLOT="0"
# ~mips removed because of broken deps. Bug #86085
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86"
IUSE="apache2 mysql pam postgres ssl minimal"

DEPEND="dev-lang/perl"
RDEPEND="${DEPEND}
	ssl? ( dev-perl/Net-SSLeay )
	mysql? ( dev-perl/DBD-mysql )
	postgres? ( dev-perl/DBD-Pg )
	pam? ( dev-perl/Authen-PAM )
	dev-perl/XML-Generator
	virtual/logger"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${PN}-1.170-setup-nocheck.patch
}

src_install() {
	# Bug #97212
	addpredict /var/lib/rpm
	# Bug #249904
	addpredict /dev/mapper/control
	addpredict /etc/lvm/cache
	# Bug #194305
	addpredict /var/spool/cron/crontabs
	# Bug 267996
	addpredict /lib/modules/$(uname -r)/kernel/net

	rm -f mount/freebsd-mounts*
	rm -f mount/netbsd-mounts*
	rm -f mount/openbsd-mounts*
	rm -f mount/macos-mounts*

	(find . -name '*.cgi' ; find . -name '*.pl') | perl perlpath.pl /usr/bin/perl -
	dodir /usr/libexec/webmin
	dodir /var

	cp -rp * "${D}"/usr/libexec/webmin

	# in webmin-minimal openslp is not present
	if [ ! -f "${D}/usr/libexec/webmin/openslp/config-gentoo-linux" ] ; then
		cp "${D}"/usr/libexec/webmin/openslp/config \
			"${D}"/usr/libexec/webmin/openslp/config-gentoo-linux
	fi

	newinitd "${FILESDIR}"/init.d.webmin webmin

	newpamd "${FILESDIR}"/webmin-pam webmin
	echo gentoo > "${D}"/usr/libexec/webmin/install-type

	# Fix ownership
	chown -R root:0 "${D}"

	dodir /etc/webmin
	dodir /var/log/webmin

	config_dir="${D}"/etc/webmin
	var_dir="${D}"/var/log/webmin
	perl=/usr/bin/perl
	autoos=1
	port=10000
	login=root
	crypt="XXX"
	host=`hostname`
	use ssl && ssl=1 || ssl=0
	atboot=0
	nostart=1
	nochown=1
	autothird=1
	nouninstall=1
	noperlpath=1
	tempdir="${T}"
	export config_dir var_dir perl autoos port login crypt host ssl atboot nostart nochown autothird nouninstall noperlpath tempdir
	"${D}"/usr/libexec/webmin/setup.sh > "${T}"/webmin-setup.out 2>&1 || die "Failed to create initial webmin configuration."

	# Fixup the config files to use their real locations
	sed -i -e "s:^pidfile=.*$:pidfile=/var/run/webmin.pid:" "${D}"/etc/webmin/miniserv.conf
	find "${D}"/etc/webmin -type f | xargs sed -i -e "s:${D}:/:g"

	# Cleanup from the config script
	rm -rf "${D}"/var/log/webmin
	keepdir /var/log/webmin/

	# Get rid of this crap...
	rm -rf "${D}"/usr/libexec/webmin/acl/Authen-SolarisRBAC-0.1
	rm -f "${D}"/usr/libexec/webmin/acl/Authen-SolarisRBAC-0.1.tar.gz
}

pkg_postinst() {
	local crypt=$(grep "^root:" "${ROOT}"/etc/shadow | cut -f 2 -d :)
	crypt=${crypt//\\/\\\\}
	crypt=${crypt//\//\\\/}
	sed -i -e "s/root:XXX/root:${crypt}/" "${ROOT}/etc/webmin/miniserv.users"

	einfo "To make webmin start at boot time, run: 'rc-update add webmin default'."
	use ssl && einfo "Point your web browser to https://localhost:10000 to use webmin."
	use ssl || einfo "Point your web browser to http://localhost:10000 to use webmin."

	einfo "NOTE: virtual-server has been removed from this ebuild."
	elog "To create a login account for webmin named \"admin\", execute the "
	elog "following command:"
	elog "/usr/libexec/webmin/changepass.pl /etc/webmin admin <new_password>"
}
