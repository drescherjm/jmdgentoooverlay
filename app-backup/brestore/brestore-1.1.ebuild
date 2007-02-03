# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-backup/bacula/bacula-1.38.5.ebuild,v 1.2 2006/02/19 03:48:29 labmonkey Exp $

inherit eutils

IUSE=""
KEYWORDS="~sparc ~x86 ~amd64"

DESCRIPTION="brestore - a bacula perl interface to bacula"
HOMEPAGE="http://cousinmarc.free.fr/"

SRC_URI="http://cousinmarc.free.fr/brestore_v1.1.tgz"

LICENSE="GPL-2"
SLOT="0"

S=${WORKDIR}/brestore.pl

DEPEND="dev-lang/perl
	app-backup/bacula
	dev-perl/gtk2-gladexml
	dev-perl/gtk2-perl
	dev-perl/gtk-perl-glade
	dev-perl/DBD-mysql
	dev-perl/DBD-Pg
	dev-perl/Expect"
RDEPEND=${DEPEND}


src_unpack() {
	unpack ${A}
	cd ${S}
}

