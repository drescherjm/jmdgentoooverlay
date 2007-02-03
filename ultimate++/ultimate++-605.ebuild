# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

DESCRIPTION="Ultimate++ Development environment"
HOMEPAGE="http://upp.sourceforge.net/"
SRC_URI=" mirror://sourceforge/upp/upp-src-605.zip"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

DEPEND=""
RDEPEND=""

src_compile(){
	econf
	emake
}
