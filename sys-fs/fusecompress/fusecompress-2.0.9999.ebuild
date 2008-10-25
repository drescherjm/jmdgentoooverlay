# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit git

DESCRIPTION="Transparent filesystem compression via FUSE. Supports lzo, gzip and bzip2"
EGIT_REPO_URI="git://github.com/tex/fusecompress.git"
EGIT_BRANCH="master"
HOMEPAGE="http://miio.net/fusecompress/"
LICENSE="GPL-2"
KEYWORDS="~x86 ~amd64"
SLOT="0"
RDEPEND=""
DEPEND=">=sys-fs/fuse-2.4.1-r1
	>=app-arch/bzip2-1.0.3-r5
	>=sys-libs/zlib-1.2.3
	>=dev-libs/rlog-1.3.7
	>=app-arch/lzma-utils-4.9999"

src_compile() {
	git_src_unpack
	econf
	emake
}

src_install() {
	dobin fusecompress
	dodoc NEWS README
}
