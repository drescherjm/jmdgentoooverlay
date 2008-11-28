# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-fs/samba/samba-3.2.4.ebuild,v 1.1 2008/10/09 15:32:53 dev-zero Exp $

inherit eutils pam multilib versionator confutils

MY_P=${PN}-${PV/_/}

DESCRIPTION="A suite of SMB and CIFS client/server programs for UNIX"
HOMEPAGE="http://www.samba.org/"
SRC_URI="mirror://samba/${MY_P}.tar.gz"
LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="acl ads async automount caps cifs_spnego cluster cups doc examples ipv6 kernel_linux kerberos ldap fam
	pam quotas readline selinux swat syslog winbind"

RDEPEND="dev-libs/popt
	dev-libs/iniparser
	virtual/libiconv
	acl? ( kernel_linux? ( sys-apps/acl ) )
	cups? ( net-print/cups )
	ipv6? ( sys-apps/xinetd )
	kerberos? ( virtual/krb5 sys-fs/e2fsprogs )
	ldap? ( net-nds/openldap )
	pam? ( virtual/pam )
	readline? ( sys-libs/readline )
	selinux? ( sec-policy/selinux-samba )
	swat? ( sys-apps/xinetd )
	syslog? ( virtual/logger )
	fam? ( virtual/fam )
	caps? ( sys-libs/libcap )
	cifs_spnego? ( sys-apps/keyutils )
	cluster? ( dev-db/ctdb )"
DEPEND="${RDEPEND}
	!net-fs/mount-cifs"

S="${WORKDIR}/${MY_P}"
CONFDIR="${FILESDIR}/config-3.2"
PRIVATE_DST=/var/lib/samba/private

# Tests are currently broken due to hardcoded paths (due to --with-fhs)
# The problem is that --without-fhs lets samba use lockdir (which can be changed in smb.conf)
# which is wrong as well.
RESTRICT="test"

pkg_setup() {
	confutils_use_depend_all cifs_spnego ads
	confutils_use_depend_all ads ldap kerberos
}

src_unpack() {
	unpack ${A}
	cd "${S}/source"

	# Ok, agreed, this is ugly. But it avoids a patch we would
	# need for every samba version and we don't need autotools
	sed -i \
		-e 's|"lib32" ||' \
		-e 's|if test -d "$i/$l" ;|if test -d "$i/$l" -o -L "$i/$l";|' \
		configure || die "sed failed"

	sed -i \
		-e 's|tdbsam|tdbsam:${PRIVATEDIR}/passdb.tdb|' \
		"${S}/source/script/tests/selftest.sh" || die "sed failed"
}

src_compile() {
	cd "${S}/source"

	local myconf
	local mymod_shared

	if use ldap && use winbind; then
		mymod_shared="--with-shared-modules=idmap_rid"
		mymod_shared="${mymod_shared},idmap_ad"
	fi

	use kernel_linux && myconf="${myconf} $(use_with cifs_spnego cifsupcall) --with-cifsmount"

	[[ ${CHOST} == *-*bsd* ]] && myconf="${myconf} --disable-pie"
	use hppa && myconf="${myconf} --disable-pie"

	use caps && export ac_cv_header_sys_capability_h=yes || export ac_cv_header_sys_capability_h=no

	econf \
		--with-fhs \
		--sysconfdir=/etc/samba \
		--localstatedir=/var \
		--with-configdir=/etc/samba \
		--with-libdir=/usr/$(get_libdir)/samba \
		--with-pammodulesdir=$(getpam_mod_dir) \
		--with-swatdir=/usr/share/${PN}/swat \
		--with-piddir=/var/run/samba \
		--with-lockdir=/var/cache/samba \
		--with-logfilebase=/var/log/samba \
		--with-privatedir=${PRIVATE_DST} \
		--with-ctdb=/usr \
		--with-libsmbclient \
		--without-spinlocks \
		--enable-socket-wrapper \
		--enable-nss-wrapper \
		--without-included-popt \
		--without-included-iniparser \
		$(use_with acl acl-support) \
		$(use_with ads) \
		$(use_with async aio-support) \
		$(use_with automount) \
		$(use_enable cups) \
		$(use_enable fam) \
		$(use_with kerberos krb5) \
		$(use_with ads dnsupdate) \
		$(use_with ldap) \
		$(use_with pam) $(use_with pam pam_smbpass) \
		$(use_with quotas) $(use_with quotas sys-quotas) \
		$(use_with readline) \
		$(use_enable swat) \
		$(use_with syslog) \
		$(use_with winbind) \
		$(use_with cluster cluster-support) \
		${myconf} ${mymod_shared} || die "econf failed"

	emake proto || die "emake proto failed"
	emake everything || die "emake everything failed"

}

src_test() {
	cd "${S}/source"
	emake test || die "tests failed"
}

src_install() {
	cd "${S}/source"

	emake DESTDIR="${D}" install-everything || die "emake install-everything failed"

	local libs="libnetapi.so.0 libsmbclient.so.0 libsmbsharemodes.so.0 libtalloc.so.1 libtdb.so.1 libwbclient.so.0"
	for lib in ${libs} ; do
		dosym samba/${lib} /usr/$(get_libdir)/${lib}
		dosym samba/${lib} /usr/$(get_libdir)/${lib%.?}
	done

	# Extra rpctorture progs
	local extra_bins="rpctorture"
	for i in ${extra_bins} ; do
		[[ -x "${S}/bin/${i}" ]] && dobin "${S}/bin/${i}"
	done

	# Nsswitch extensions. Make link for wins and winbind resolvers
	if use winbind ; then
		dolib.so nsswitch/libnss_wins.so
		dosym libnss_wins.so /usr/$(get_libdir)/libnss_wins.so.2
		dolib.so nsswitch/libnss_winbind.so
		dosym libnss_winbind.so /usr/$(get_libdir)/libnss_winbind.so.2
	fi

	if use kernel_linux ; then
		dosym ../usr/sbin/mount.cifs /usr/bin/mount.cifs
		dosym ../usr/sbin/umount.cifs /usr/bin/umount.cifs
		# Warning: this can byte you if /usr is
		# on a separate volume and you have to mount
		# a smb volume before the local mount
		dosym ../usr/sbin/mount.cifs /sbin/mount.cifs
		dosym ../usr/sbin/umount.cifs /sbin/umount.cifs
		#
		fperms 4755 /usr/sbin/mount.cifs
		fperms 4755 /usr/sbin/umount.cifs
	fi

	# make the smb backend symlink for cups printing support (bug #133133)
	if use cups ; then
		dodir $(cups-config --serverbin)/backend
		dosym /usr/bin/smbspool $(cups-config --serverbin)/backend/smb
	fi

	cd "${S}/source"

	# General config files
	insinto /etc/samba
	doins "${CONFDIR}"/{smbusers,lmhosts}
	doins "${CONFDIR}/smb.conf.example"

	newpamd "${CONFDIR}/samba.pam" samba
	use winbind && dopamd "${CONFDIR}/system-auth-winbind"
	if use swat ; then
		insinto /etc/xinetd.d
		newins "${CONFDIR}/swat.xinetd" swat
	else
		rm -f "${D}/usr/share/man/man8/swat.8"
	fi

	newinitd "${FILESDIR}/samba-init" samba
	newconfd "${FILESDIR}/samba-conf" samba

	if use ldap ; then
		insinto /etc/openldap/schema
		doins "${S}/examples/LDAP/samba.schema"
	fi

	if use ipv6 ; then
		insinto /etc/xinetd.d
		newins "${FILESDIR}/samba-xinetd" smb
	fi

	# dirs
	diropts -m0700 ; keepdir "${PRIVATE_DST}"
	diropts -m1777 ; keepdir /var/spool/samba

	diropts -m0755
	keepdir /var/{log,run,cache}/samba
	keepdir /var/lib/samba/{netlogon,profiles}
	keepdir /var/lib/samba/printers/{W32X86,WIN40,W32ALPHA,W32MIPS,W32PPC,X64,IA64,COLOR}
	keepdir /usr/$(get_libdir)/samba/{rpc,idmap,auth}

	# docs
	dodoc "${FILESDIR}/README.gentoo"
	dodoc "${S}"/{MAINTAINERS,README,Roadmap,WHATSNEW.txt}
	dodoc "${CONFDIR}/nsswitch.conf-wins"
	use winbind && dodoc "${CONFDIR}/nsswitch.conf-winbind"

	if use examples ; then
		insinto /usr/share/doc/${PF}
		doins -r "${S}/examples/"
		find "${D}/usr/share/doc/${PF}" -type d -print0 | xargs -0 chmod 755
		find "${D}/usr/share/doc/${PF}/examples" ! -type d -print0 | xargs -0 chmod 644
	fi

	if ! use doc ; then
		if ! use swat ; then
			rm -rf "${D}/usr/share/doc/${PF}/swat"
		else
			rm -rf "${D}/usr/share/doc/${PF}/swat/help"/{guide,howto,devel}
			rm -rf "${D}/usr/share/doc/${PF}/swat/using_samba"
		fi
	else
		cd "${S}/docs"
		insinto /usr/share/doc/${PF}
		doins *.pdf
		doins -r registry
		dohtml -r htmldocs/*
	fi

}

pkg_preinst() {
	local PRIVATE_SRC=/etc/samba/private
	if [[ ! -r "${ROOT}/${PRIVATE_DST}/secrets.tdb" \
		&& -r "${ROOT}/${PRIVATE_SRC}/secrets.tdb" ]] ; then
		ebegin "Copying ${ROOT}/${PRIVATE_SRC}/* to ${ROOT}/${PRIVATE_DST}/"
			mkdir -p "${D}/${PRIVATE_DST}"
			cp -pPRf "${ROOT}/${PRIVATE_SRC}"/* "${D}/${PRIVATE_DST}/"
		eend $?
	fi

	if [[ ! -f "${ROOT}/etc/samba/smb.conf" ]] ; then
		touch "${D}/etc/samba/smb.conf"
	fi
}

pkg_postinst() {
	if use swat ; then
		einfo "swat must be enabled by xinetd:"
		einfo "  change the /etc/xinetd.d/swat configuration"
	fi

	if use ipv6 ; then
		einfo "ipv6 support must be enabled by xinetd:"
		einfo "  change the /etc/xinetd.d/smb configuration"
	fi

	elog "It is possible to start/stop daemons separately:"
	elog "  Create a symlink from /etc/init.d/samba.{smbd,nmbd,winbind} to"
	elog "  /etc/init.d/samba. Calling /etc/init.d/samba directly will start"
	elog "  the daemons configured in /etc/conf.d/samba"

	elog "The mount/umount.cifs helper applications are included per my own" 
	elog "personal preference. Suggest a 'minimal' use flag to install only the"
	elog "helper apps. I think it's easier to keep everything in sync this way"

	ewarn "If you're upgrading from 3.0.24 or earlier, please make sure to"
	ewarn "restart your clients to clear any cached information about the server."
	ewarn "Otherwise they might not be able to connect to the volumes."
}
