# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-misc/unison/unison-2.12.0.ebuild,v 1.6 2005/09/01 13:54:44 gustavoz Exp $

inherit eutils

IUSE="gtk gtk2 static debug threads"

DESCRIPTION="Two-way cross-platform file synchronizer"
HOMEPAGE="http://www.cis.upenn.edu/~bcpierce/unison/"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="x86 ppc ~amd64 sparc"

DEPEND=">=dev-lang/ocaml-3.04
	gtk? ( gtk2? ( >=dev-ml/lablgtk-2.2 ) !gtk2? ( =dev-ml/lablgtk-1.2* ) )"

RDEPEND="gtk? ( gtk2? ( >=dev-ml/lablgtk-2.2 ) !gtk2? ( =dev-ml/lablgtk-1.2* )
|| ( net-misc/x11-ssh-askpass net-misc/gtk2-ssh-askpass ) )"

SRC_URI="http://www.cis.upenn.edu/~bcpierce/unison/download/releases/stable/${P}.tar.gz"

src_unpack() {
	unpack ${P}.tar.gz

	# Fix for coreutils change of tail syntax
	cd ${S}
	sed -i -e 's/tail -1/tail -n 1/' Makefile.OCaml
#	# Fix for bad button behavior
#	epatch ${FILESDIR}/${P}-gtk2-bug.patch
}

src_compile() {
	local myconf

	if use threads; then
		myconf="$myconf THREADS=true"
	fi

	if use static; then
		myconf="$myconf STATIC=true"
	fi

	if use debug; then
		myconf="$myconf DEBUGGING=true"
	fi

	if use gtk; then
		if use gtk2; then
			myconf="$myconf UISTYLE=gtk2"
		else
			myconf="$myconf UISTYLE=gtk"
		fi
	else
		myconf="$myconf UISTYLE=text"
	fi

	make $myconf CFLAGS="" || die "error making unsion"
}

src_install () {
	# install manually, since it's just too much
	# work to force the Makefile to do the right thing.
	dobin unison || die
	dodoc BUGS.txt CONTRIB COPYING INSTALL NEWS \
	      README ROADMAP.txt TODO.txt || die
}
