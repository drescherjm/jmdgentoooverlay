# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-block/partimage/partimage-0.6.4-r4.ebuild,v 1.8 2005/12/31 14:11:38 flameeyes Exp $

inherit eutils flag-o-matic pam

DESCRIPTION="Console-based application to efficiently save raw partition data to an image file. Optional encryption/compression support."
HOMEPAGE="http://www.partimage.org/"
SRC_URI="mirror://sourceforge/partimage/${P}.tar.bz2"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*- ~x86 ~ppc ~sparc"
IUSE="ssl nologin nls pam static"

DEPEND="virtual/libc
	>=sys-libs/zlib-1.1.4
	>=dev-libs/newt-0.51.6
	app-arch/bzip2
	>=sys-libs/slang-1.4.5-r2
	nls? ( sys-devel/gettext )
	ssl? ( >=dev-libs/openssl-0.9.6g )
	sys-devel/autoconf"

RDEPEND="!static? ( virtual/libc
		>=sys-libs/zlib-1.1.4
		>=dev-libs/lzo-1.08
		>=dev-libs/newt-0.51.6
		app-arch/bzip2
		>=sys-libs/slang-1.4.5-r2
		nls? ( sys-devel/gettext )
		ssl? ( >=dev-libs/openssl-0.9.6g )
		pam? ( virtual/pam )
	)"

PARTIMAG_GROUP_GID=91
PARTIMAG_USER_UID=91
PARTIMAG_GROUP_NAME=partimag
PARTIMAG_USER_NAME=partimag
PARTIMAG_USER_SH=-1
PARTIMAG_USER_HOMEDIR=/var/log/partimage
PARTIMAG_USER_GROUPS=partimag

pkg_setup() {
	# Now add users if needed
	enewgroup ${PARTIMAG_GROUP_NAME} ${PARTIMAG_GROUP_GID}
	enewuser ${PARTIMAG_USER_NAME} ${PARTIMAG_USER_UID} ${PARTIMAG_USER_SH} ${PARTIMAG_USER_HOMEDIR} ${PARTIMAG_USER_GROUPS}
}

src_unpack() {
	unpack ${A}
	cd ${S}

	# we can do better security ourselves
#	epatch ${FILESDIR}/${P}-nodumbpermchecks.diff || die
#	epatch ${FILESDIR}/${P}-chown.patch || die
#	epatch ${FILESDIR}/${P}-not_install_info.patch || die
#	epatch ${FILESDIR}/${P}-fixserverargs.diff || die
#	epatch ${FILESDIR}/${P}-lib64.patch || die
#	epatch ${FILESDIR}/${P}-fflush-before-re-read-partition-table.patch || die
#	epatch ${FILESDIR}/${P}-LP64-fixes.patch || die
#	epatch ${FILESDIR}/${P}-save_all_and_rest_all_actions.patch || die
#	epatch ${FILESDIR}/${P}-datadir-path.patch || die
}

src_compile() {
	filter-flags -fno-exceptions

	local myconf
	use nologin && myconf="${myconf} --disable-login"
	if use static
	then
		use pam && ewarn "pam and static compilation are mutually exclusive - using static and ignoring pam"
	else
		myconf="${myconf} `use_enable pam`"
	fi
	econf \
		${myconf} \
		--sysconfdir=/etc \
		`use_enable ssl` \
		`use_enable nls` \
		`use_enable static all-static` \
		|| die "econf failed"

	emake || die "make failed"
	if use pam
	then
		make pamfile || die  "couldn't create pam file"
	fi
}

src_install() {
	emake DESTDIR=${D} \
		MKINSTALLDIRS=/usr/share/automake-1.8/mkinstalldirs install || die

	keepdir /var/log/partimage

	insinto /etc/partimaged; doins ${FILESDIR}/servercert.cnf || die

	# init.d / conf.d
	exeinto /etc/init.d ; newexe ${FILESDIR}/${PN}d.init ${PN}d || die
	insinto /etc/conf.d ; newins ${FILESDIR}/${PN}d.conf ${PN}d || die

	doman debian/partimage.1 debian/partimaged.8 ${FILESDIR}/partimagedusers.5 || die
	dodoc AUTHORS BUGS COPYING ChangeLog INSTALL README* TODO partimage.lsm

	# pam
	newpamd partimaged.pam partimaged
}

# vars for SSL stuff
confdir="${ROOT}etc/partimaged"
privkey="${confdir}/partimaged.key"
cnf="${confdir}/servercert.cnf"
csr="${confdir}/partimaged.csr"
cert="${confdir}/partimaged.cert"

pkg_config() {
	if use ssl; then
		ewarn "Please customize /etc/partimaged/servercert.cnf before you continue!"
		ewarn "Press Ctrl-C to break now for it, or press enter to continue."
		read
		if [ ! -f ${privkey} ]; then
			einfo "Generating unencrypted private key: ${privkey}"
			openssl genrsa -out ${privkey} 1024  || die "Failed!"
		else
			einfo "Private key already exists: ${privkey}"
		fi
		if [ ! -f ${csr} ]; then
			einfo "Generating certificate request: ${csr}"
			openssl req -new -x509 -outform PEM -out ${csr} -key ${privkey} -config ${cnf} || die "Failed!"
		else
			einfo "Certificate request already exists: ${csr}"
		fi
		if [ ! -f ${cert} ]; then
			einfo "Generating self-signed certificate: ${cert}"
			openssl x509 -in ${csr} -out ${cert} -signkey ${privkey} || die "Failed!"
		else
			einfo "Self-signed certifcate already exists: ${cert}"
		fi
		einfo "Setting permissions"
		partimagesslperms || die "Failed!"
		einfo "Done"
	else
		einfo "SSL is disabled, not building certificates"
	fi
}

partimagesslperms() {
	local ret=0
	chmod 600 ${privkey} 2>/dev/null
	ret=$((${ret}+$?))
	chown partimag:0 ${privkey} 2>/dev/null
	ret=$((${ret}+$?))
	chmod 644 ${cert} ${csr} 2>/dev/null
	ret=$((${ret}+$?))
	chown root:0 ${cert} ${csr} 2>/dev/null
	ret=$((${ret}+$?))
	return $ret
}

pkg_postinst() {
	if use ssl; then
		einfo "To create the required SSL certificates, please do:"
		einfo "emerge  --config =${PF}"
		# force a permmissions fixup
		partimagesslperms
		return 0
	fi
}
