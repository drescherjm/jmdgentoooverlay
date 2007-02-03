# Copyright 1999-2003 Gentoo Technologies, Inc.
# Distributed under the terms of the GNU General Public License v2
# $Header: $

DESCRIPTION="A set of command-line tools for DVB cards such as the Hauppauge DVB-S and Nova-t. "
HOMEPAGE="http://sourceforge.net/projects/dvbtools/"
SRC_URI="mirror://sourceforge/dvbtools/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="x86 ~alpha ~ia64 ~amd64 ~ppc"

DEPEND=">=sys-kernel/linux-headers-2.6.4"
RDEPEND=">=dev-libs/libxml2-2.6.6"


src_unpack() {
	unpack ${A} && cd "${S}"

}

src_compile() {
	emake || die "compile problem"
}

src_install() {
	dobin dvbtune
}
