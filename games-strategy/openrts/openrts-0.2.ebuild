# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit games

DESCRIPTION=""
HOMEPAGE=""
SRC_URI="http://download.gna.org/openrts/"${P}"-src.zip"

LICENSE=""
SLOT="0"
KEYWORDS="~x86"
IUSE=""

DEPEND=""
RDEPEND=""

src_compile() {
	 emake || die "make failed"
}
