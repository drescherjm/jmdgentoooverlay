# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

AUTOTOOLS_AUTORECONF=1

#inherit autotools-utils
inherit autotools

DESCRIPTION="DBus service for configuring kerberos and other online identities"
#HOMEPAGE="http://cgit.freedesktop.org/realmd/realmd/"
#SRC_URI="http://cgit.freedesktop.org/realmd/realmd/snapshot/${P}.zip"
HOMEPAGE="https://github.com/freedesktop/realmd"
SRC_URI="https://github.com/freedesktop/realmd/archive/refs/tags/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="LGPL-2+"
SLOT="0"
KEYWORDS="~amd64"
IUSE="doc nls systemd"

DEPEND=""
RDEPEND="${DEPEND}"

src_prepare() {
   default
   eautoreconf
}

src_configure() {
	local myeconfargs=(
		--with-distro=debian # service/realmd-[DISTRO].conf; could patch to add a Gentoo file
		# nls || --disable-nls
		$(use_enable doc)
		$(use_enable nls)
		$(use_with systemd systemd_unit_dir)
		$(use_with systemd systemd_journal)
		--with-new-samba-cli-options=no # samba-4.15 or newer? yes causes sandbox violations
	)
	econf "${myeconfargs[@]}"
}
