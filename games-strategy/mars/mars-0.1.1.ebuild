# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-backup/bacula/bacula-1.38.5.ebuild,v 1.2 2006/02/19 03:48:29 labmonkey Exp $

inherit eutils

IUSE=""
KEYWORDS="~x86 ~amd64"

DESCRIPTION="Featureful client/server network backup suite"
HOMEPAGE="http://sourceforge.net/projects/mars"

SRC_URI="mirror://sourceforge/mars/${P}-src.tar.gz"

LICENSE="GPL-2"
SLOT="0"

DEPEND="dev-util/scons"
RDEPEND="${DEPEND}"

src_unpack() {
	unpack ${A}
	cd ${S}
}

src_compile() {
	pwd

	scons
	
}


