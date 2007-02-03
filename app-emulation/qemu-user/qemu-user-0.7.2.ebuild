# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-emulation/qemu-user/qemu-user-0.7.1.ebuild,v 1.2 2005/08/06 14:15:36 lu_zero Exp $

inherit eutils flag-o-matic

DESCRIPTION="Multi-platform & multi-targets cpu emulator and dynamic translator"
HOMEPAGE="http://fabrice.bellard.free.fr/qemu/"
SRC_URI="http://fabrice.bellard.free.fr/qemu/${P/-user}.tar.gz"
#qvm86? ( http://dev.gentoo.org/~lu_zero/distfiles/qvm86-20050409.tar.bz2 )"
#kqemu? ( http://fabrice.bellard.free.fr/qemu/kqemu-${PV%.*}-1.tar.gz )

LICENSE="GPL-2 LGPL-2.1"
SLOT="0"
KEYWORDS="~x86 ~ppc -alpha -sparc ~amd64"
IUSE=""  #qvm86 debug nptl qemu-fast nptlonly"
RESTRICT="nostrip"

DEPEND="virtual/libc
	app-text/texi2html
	!<=app-emulation/qemu-0.7.0"
RDEPEND=""

S="${WORKDIR}/${P/-user}"

set_target_list() {
	TARGET_LIST="arm-user armeb-user i386-user ppc-user sparc-user"
	export TARGET_LIST
}

pkg_setup() {
	if [ "$(gcc-major-version)" == "4" ]; then
		ewarn "Qemu could not build with GCC 4"
	fi
}

#RUNTIME_PATH="/emul/gnemul/"
src_unpack() {
	unpack ${A}

	cd ${S}
	epatch ${FILESDIR}/qemu-ppc-dirty-hack.patch
	# Alter target makefiles to accept CFLAGS set via flag-o.
	sed -i 's/^\(C\|OP_C\|HELPER_C\)FLAGS=/\1FLAGS+=/' \
		Makefile Makefile.target tests/Makefile
	# Ensure mprotect restrictions are relaxed for emulator binaries
	[[ -x /sbin/paxctl ]] && \
		sed -i 's/^VL_LDFLAGS=$/VL_LDFLAGS=-Wl,-z,execheap/' \
			Makefile.target
	# Prevent install of kernel module by qemu's makefile
	sed -i 's/\(.\/install.sh\)/#\1/' Makefile
}

src_compile() {
	#Let the application set its cflags
	unset CFLAGS

	# Switch off hardened tech
	filter-flags -fpie -fstack-protector

	myconf=""
	set_target_list
#		--interp-prefix=${RUNTIME_PATH}/qemu-%M
	./configure \
		--prefix=/usr \
		--target-list="${TARGET_LIST}" \
		--enable-slirp \
		--kernel-path=${KV_DIR} \
		${myconf} \
		|| die "could not configure"

	emake || die "make failed"
}

src_install() {
	make install \
		prefix=${D}/usr \
		bindir=${D}/usr/bin \
		datadir=${D}/usr/share/qemu \
		docdir=${D}/usr/share/doc/${P} \
		mandir=${D}/usr/share/man || die

	rm -fR ${D}/usr/share/{man,qemu}
	rm -fR ${D}/usr/bin/qemu-img
}
