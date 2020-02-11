# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit autotools

DESCRIPTION="Rdfind is a program that finds duplicate files."
HOMEPAGE="https://github.com/pauldreik/rdfind"
SRC_URI="https://github.com/pauldreik/rdfind/archive/releases/${PV}.tar.gz"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="~amd64 ~arm ~x86"
IUSE=""

DEPEND="dev-libs/nettle"
RDEPEND="${DEPEND}"

S="${WORKDIR}/${PN}-releases-${PV}"

src_prepare() {
	# NOTE: Commands are from bootstrap.sh.
	eaclocal
	eautoheader
	eautomake --add-missing
	eautoconf
	default
}
