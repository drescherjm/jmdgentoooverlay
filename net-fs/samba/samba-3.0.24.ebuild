# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-fs/samba/samba-3.0.23d.ebuild,v 1.3 2007/01/08 15:33:14 flameeyes Exp $

WANT_AUTOCONF="latest"
inherit eutils autotools versionator pam

IUSE_LINGUAS="ja pl"
IUSE="acl async automount cups doc examples kerberos kernel_linux ldap fam
	linguas_ja linguas_pl
	oav pam python quotas readline selinux swat syslog winbind"
#RESTRICT="test" # tests are enabled with --enable-socket-wrapper

VSCAN_VER="0.3.6b"
PATCH_VER="0.3.15"
MY_P=${PN}-${PV/_/}
MY_PP=${PN}-$(get_major_version)-gentoo-${PATCH_VER}
S2=${WORKDIR}/${MY_P}
S=${S2}/source
PFVSCAN=${PN}-vscan-${VSCAN_VER}
DESCRIPTION="SAMBA is a suite of SMB and CIFS client/server programs for UNIX"
HOMEPAGE="http://www.samba.org/ http://www.openantivirus.org/projects.php"
SRC_URI="mirror://gentoo/${MY_PP}.tar.bz2
	mirror://samba/${MY_P}.tar.gz
	mirror://samba/old-versions/${MY_P}.tar.gz
	oav? ( mirror://sourceforge/openantivirus/${PFVSCAN}.tar.bz2 )"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~sparc-fbsd ~x86 ~x86-fbsd"

RDEPEND="dev-libs/popt
	virtual/libiconv
	acl?       ( kernel_linux? ( sys-apps/acl ) )
	cups?      ( net-print/cups )
	ldap?      ( kerberos? ( virtual/krb5 ) net-nds/openldap )
	pam?       ( virtual/pam )
	python?    ( dev-lang/python )
	readline?  ( sys-libs/readline )
	selinux?   ( sec-policy/selinux-samba )
	swat?      ( sys-apps/xinetd )
	syslog?    ( virtual/logger )
	fam?       ( virtual/fam )
	"
DEPEND="${RDEPEND}
	sys-devel/autoconf
	>=sys-apps/sed-4"

PRIVATE_DST=/var/lib/samba/private
PATCHDIR=${WORKDIR}/patches
CONFDIR=${WORKDIR}/configs

src_unpack() {
	unpack ${A}
	cd "${S2}"

	rm -rf ${S2}/examples.ORIG

	export EPATCH_SUFFIX="patch"
	epatch ${PATCHDIR}/general
	if use oav ; then
		cd ${WORKDIR}
		if [[ -d ${PATCHDIR}/vscan ]] ; then
			epatch ${PATCHDIR}/vscan
		fi
		cp -pPR ${WORKDIR}/${PFVSCAN} ${S2}/examples/VFS
	fi

	# patches screw with autotool files
	cd "${S}"
	eautoconf
}

src_compile() {
	local myconf
	local mylangs
	local mymod_shared

	mylangs="--with-manpages-langs=en"
	use linguas_ja && mylangs="${mylangs},ja"
	use linguas_pl && mylangs="${mylangs},pl"

	use winbind && mymod_shared="--with-shared-modules=idmap_rid"
	if use ldap ; then
		myconf="${myconf} $(use_with kerberos ads)"
		use winbind && mymod_shared="${mymod_shared},idmap_ad"
	fi

	[[ ${CHOST} == *-*bsd* ]] && myconf="${myconf} --disable-pie"
	use hppa && myconf="${myconf} --disable-pie"

	use fam && export ac_cv_header_fam_h=yes || export ac_cv_header_fam_h=no
	econf \
		--with-fhs \
		--sysconfdir=/etc/samba \
		--localstatedir=/var \
		--with-configdir=/etc/samba \
		--with-libdir=/usr/$(get_libdir)/samba \
		--with-swatdir=/usr/share/doc/${PF}/swat \
		--with-piddir=/var/run/samba \
		--with-lockdir=/var/cache/samba \
		--with-logfilebase=/var/log/samba \
		--with-privatedir=${PRIVATE_DST} \
		--with-libsmbclient \
		--without-spinlocks \
		--enable-socket-wrapper \
		$(use_with acl acl-support) \
		$(use_with async aio-support) \
		$(use_with automount) \
		$(use_enable cups) \
		$(use_with kerberos krb5) \
		$(use_with ldap) \
		$(use_with pam) $(use_with pam pam_smbpass) \
		$(use_with python) \
		$(use_with quotas) $(use_with quotas sys-quotas) \
		$(use_with readline) \
		$(use_with kernel_linux smbmount) \
		$(use_with syslog) \
		$(use_with winbind) \
		${myconf} ${mylangs} ${mymod_shared} || die

	emake proto || die "SAMBA make proto error"
	emake everything || die "SAMBA make everything error"

	emake rpctorture >& rpctorture.log || ewarn "rpctorture didn't build [that's ok!]"

	if use python ; then
		python python/setup.py build
	fi

	# Build samba-vscan plugins
	if use oav ; then
		cd ${S2}/examples/VFS/${PFVSCAN}
		econf \
			--with-fhs \
			--libdir=/usr/$(get_libdir)/samba \
			|| die "${PFVSCAN} ./configure failed"
		emake || die "Failed to make ${PFVSCAN}"
	fi

}

src_install() {
	local extra_bins="rpctorture"

	emake DESTDIR="${D}" install-everything || die

	# Extra rpctorture progs
	for i in ${extra_bins} ; do
		[[ -x ${S}/bin/${i} ]] && dobin "${S}"/bin/${i}
	done

	# remove .old stuff from /usr/bin:
	rm -f "${D}"/usr/bin/*.old

	# Nsswitch extensions. Make link for wins and winbind resolvers
	if use winbind ; then
		dolib.so "${S}"/nsswitch/libnss_wins.so || die
		dosym libnss_wins.so /usr/$(get_libdir)/libnss_wins.so.2
		dolib.so "${S}"/nsswitch/libnss_winbind.so || die
		dosym libnss_winbind.so /usr/$(get_libdir)/libnss_winbind.so.2
	fi

	if use pam ; then
		exeinto /$(get_libdir)/security
		doexe "${S}"/bin/pam_smbpass.so || die
		if use winbind ; then
			exeinto /$(get_libdir)/security
			doexe "${S}"/bin/pam_winbind.so || die
		fi
	fi

	if use kernel_linux ; then
		# mount backend
		dodir /sbin
		dosym ../usr/bin/smbmount /sbin/mount.smbfs
		dosym ../usr/bin/mount.cifs /sbin/mount.cifs
	fi

	# bug #46389: samba doesn't create symlink anymore
	# beaviour seems to be changed in 3.0.6, see bug #61046
	dosym samba/libsmbclient.so /usr/$(get_libdir)/libsmbclient.so.0
	dosym samba/libsmbclient.so /usr/$(get_libdir)/libsmbclient.so

	# make the smb backend symlink for cups printing support (bug #133133)
	if use cups ; then
		dodir $(cups-config --serverbin)/backend
		dosym /usr/bin/smbspool $(cups-config --serverbin)/backend/smb
	fi

	# VFS plugin modules
	if use oav ; then
		cd ${S2}/examples/VFS/${PFVSCAN}
		make install DESTDIR=${D} || die "VFS: vscan error"
		insinto /etc/samba
		doins ${S2}/examples/VFS/${PFVSCAN}/openantivirus/*conf
	fi

	# Python extensions
	if use python ; then
		cd ${S}
		python python/setup.py install --root=${D} || die
	fi

	# General config files
	insinto /etc/samba
	doins ${CONFDIR}/smbusers
	newins ${CONFDIR}/smb.conf.example-samba3 smb.conf.example
	doins ${CONFDIR}/lmhosts

	newpamd ${CONFDIR}/samba.pam samba
	use winbind && doins ${CONFDIR}/system-auth-winbind
	if use swat ; then
		insinto /etc/xinetd.d
		newins ${CONFDIR}/swat.xinetd swat
	else
		rm -f "${D}"/usr/sbin/swat
		rm -f "${D}"/usr/share/man/man8/swat.8
	fi
	newinitd ${CONFDIR}/samba-init samba
	newconfd ${CONFDIR}/samba-conf samba
	if use ldap ; then
		insinto /etc/openldap/schema
		doins ${S2}/examples/LDAP/samba.schema
	fi

	# dirs
	diropts -m0700 ; keepdir ${PRIVATE_DST}
	diropts -m1777 ; keepdir /var/spool/samba

	diropts -m0755
	keepdir /var/{log,run,cache}/samba
	keepdir /var/lib/samba/{netlogon,profiles}
	keepdir /var/lib/samba/printers/{W32X86,WIN40,W32ALPHA,W32MIPS,W32PPC}
	keepdir /usr/$(get_libdir)/samba/{rpc,idmap,auth}

	# docs
	dodoc ${FILESDIR}/README.gentoo
	dodoc ${S2}/{COPYING,Manifest,README,Roadmap,WHATSNEW.txt}
	dodoc ${CONFDIR}/nsswitch.conf-wins
	use winbind && dodoc ${CONFDIR}/nsswitch.conf-winbind

	if use oav ; then
		docinto ${PFVSCAN}
		cd ${WORKDIR}/${PFVSCAN}
		dodoc AUTHORS COPYING ChangeLog FAQ INSTALL NEWS README TODO
		dodoc */*.conf
	fi

	if use examples ; then
		docinto examples
		cp -pPR ${S2}/examples/* "${D}"/usr/share/doc/${PF}/examples
		find "${D}"/usr/share/doc/${PF} -type d -print0 | xargs -0 chmod 755
		find "${D}"/usr/share/doc/${PF}/examples ! -type d -print0 | xargs -0 chmod 644
	fi

	if ! use doc ; then
		if ! use swat ; then
			rm -rf "${D}"/usr/share/doc/${PF}/swat
		else
			rm -rf "${D}"/usr/share/doc/${PF}/swat/help/{guide,howto,devel}
			rm -rf "${D}"/usr/share/doc/${PF}/swat/using_samba
		fi
	fi

	# Patch ChangeLog
	docinto gentoo
	dodoc ${PATCHDIR}/ChangeLog
}

pkg_preinst() {
	local PRIVATE_SRC=/etc/samba/private
	if [[ ! -r ${ROOT}/${PRIVATE_DST}/secrets.tdb \
		&& -r ${ROOT}/${PRIVATE_SRC}/secrets.tdb ]] ; then
		ebegin "Copying ${ROOT}/${PRIVATE_SRC}/* to ${ROOT}/${PRIVATE_DST}/"
			mkdir -p "${D}"/${PRIVATE_DST}
			cp -pPRf "${ROOT}"/${PRIVATE_SRC}/* "${D}"/${PRIVATE_DST}/
		eend $?
	fi

	if [[ ! -f ${ROOT}/etc/samba/smb.conf ]] ; then
		touch "${D}"/etc/samba/smb.conf
	fi
}

pkg_postinst() {
	if use swat ; then
		einfo "swat must be enabled by xinetd:"
		einfo "    change the /etc/xinetd.d/swat configuration"
	fi
	einfo "Latest info: README.gentoo in documentation directory"
}

pkg_postrm(){
	# If stale docs, and one isn't re-emerging the latest version, removes
	# (this is actually a portage bug, though)
	[[ -n ${PF} && ! -f ${ROOT}/usr/lib/${PN}/en.msg ]] && \
		rm -rf "${ROOT}"/usr/share/doc/${PF}
}
