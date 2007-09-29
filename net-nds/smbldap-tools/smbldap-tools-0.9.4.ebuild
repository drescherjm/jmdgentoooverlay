# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-nds/smbldap-tools/smbldap-tools-0.9.2a.ebuild,v 1.2 2007/07/15 23:05:11 mr_bones_ Exp $

inherit eutils

DESCRIPTION="Idealx samba ldap management tools"
SRC_URI="http://download.gna.org/smbldap-tools/packages/${P}.tgz"
HOMEPAGE="http://samba.idealx.org"

IUSE="doc"

RDEPEND="
	net-nds/openldap
	>=net-fs/samba-3.0.1
	dev-perl/perl-ldap
	dev-perl/Crypt-SmbHash
	dev-perl/Digest-SHA1
	dev-perl/Unicode-MapUTF8
	"

DEPEND="${DEPEND}
	>sys-apps/sed-4
	"
LICENSE="GPL-2"
SLOT="0"
# Waiting for the test of dev-perl/Unicode-MapUTF8
KEYWORDS="~alpha ~hppa ~ia64 ~ppc ~ppc64 ~sparc ~x86 ~amd64"

src_unpack() {
	unpack ${A}; cd ${S}

	# conf install path cleanup
	sed -i "s:/etc/opt/IDEALX/\(smbldap-tools/\):/etc/\1:g" smbldap_tools.pm
	sed -i "s:/etc/opt/IDEALX/\(smbldap-tools/\):/etc/\1:g" configure.pl
	sed -i "s:/etc/opt/IDEALX:/etc:g" smbldap.conf
}

src_compile() {
	einfo "COMPILE: nothing to compile; scripts package"
}

src_install() {
	cd ${WORKDIR}/${S}
	emake install prefix=${D}/usr sysconfdir=${D}/etc || die

	into /usr
	dosbin configure.pl

	rm -f ${D}/usr/sbin/*.spec
	#docs
	dodoc CONTRIBUTORS COPYING ChangeLog FILES INFRA INSTALL README TODO
	if use doc; then
		insinto /usr/share/doc/${PF}/doc;      doins doc/*
		insinto /usr/share/doc/${PF}/doc/html; doins doc/html/*
	fi
}

pkg_postinst() {
	einfo "A good howto is found on http://samba.idealx.org"
	einfo "(or at http://sourceforge.net/project/showfiles.php?group_id=166108)"
}
