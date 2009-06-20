# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $
inherit distutils

DESCRIPTION="Import your images efficiently and reliably"
HOMEPAGE="http://damonlynch.net/rapid/"
SRC_URI="http://launchpad.net/rapid/0.1.0/${PV}/+download/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND=">=dev-lang/python-2.5
         >=dev-python/gnome-python-2.18
         >=dev-python/pygtk-2.10
         >=media-gfx/pyexiv2-0.1.1
         dev-python/notify-python
	 dev-python/dbus-python"

DEPEND="${RDEPEND}"


src_compile() {
	distutils_src_compile || die
}

src_install( ) {
	distutils_src_install
}
