# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-arch/lzma-utils/lzma-utils-4.32.7.ebuild,v 1.1 2008/08/17 14:06:59 vapier Exp $

# Remember: we cannot leverage autotools in this ebuild in order
#           to avoid circular deps with autotools

inherit eutils git

MY_P="lzma-${PV/_}"
DESCRIPTION="LZMA interface made easy"
HOMEPAGE="http://tukaani.org/lzma/"
#SRC_URI="http://tukaani.org/lzma/${MY_P}.tar.gz
#	nocxx? ( mirror://gentoo/${PN}-4.32.6-nocxx.patch.bz2 )"

EGIT_REPO_URI="git://ctrl.tukaani.org/lzma-utils.git"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~sparc-fbsd ~x86 ~x86-fbsd"
IUSE=""

RDEPEND="!app-arch/lzma
	!<app-arch/p7zip-4.57"

S=${WORKDIR}/${MY_P}

src_unpack() {
        git_src_unpack
	cd "${S}"
	if [[ ! -e configure ]] ; then
    	   ./autogen.sh || die "autogen failed"
  	fi 

#	unpack ${A}
#	cd "${S}"
#	if use nocxx ; then
#		epatch "${WORKDIR}"/${PN}-4.32.6-nocxx.patch
#		find -type f -print0 | xargs -0 touch -r configure
#		epunt_cxx
#	fi
}

src_install() {
	emake install DESTDIR="${D}" || die
	dodoc AUTHORS ChangeLog NEWS README THANKS
	use nocxx && newbin "${FILESDIR}"/lzma-nocxx.sh lzma
}

pkg_postinst() {
	if use nocxx ; then
		ewarn "You have a neutered lzma package install due to USE=nocxx."
		ewarn "You will only be able to unpack lzma archives."
	fi
}
