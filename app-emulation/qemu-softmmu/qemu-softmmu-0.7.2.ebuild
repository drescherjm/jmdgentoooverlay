# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-emulation/qemu-softmmu/qemu-softmmu-0.7.1-r1.ebuild,v 1.3 2005/08/19 21:37:02 agriffis Exp $

inherit eutils flag-o-matic linux-mod toolchain-funcs

DESCRIPTION="Multi-platform & multi-targets cpu emulator and dynamic translator"
HOMEPAGE="http://fabrice.bellard.free.fr/qemu/"
SRC_URI="${HOMEPAGE}${P/-softmmu}.tar.gz
	kqemu? ( ${HOMEPAGE}kqemu-${PV}.tar.gz )"
#qvm86? ( http://dev.gentoo.org/~lu_zero/distfiles/qvm86-20050409.tar.bz2 )"
#kqemu? ( http://fabrice.bellard.free.fr/qemu/kqemu-${PV%.*}-1.tar.gz )

LICENSE="GPL-2 LGPL-2.1 KQEMU"
SLOT="0"
KEYWORDS="~x86 ~ppc -alpha -sparc ~amd64"
IUSE="sdl kqemu"  #qvm86 debug nptl qemu-fast nptlonly"
RESTRICT="nostrip"

DEPEND="virtual/libc
	sdl? ( media-libs/libsdl )
	!<=app-emulation/qemu-0.7.0
	app-text/texi2html"
RDEPEND="sdl? ( media-libs/libsdl )"

S="${WORKDIR}/${P/-softmmu}"

set_target_list() {
	TARGET_LIST="i386-softmmu ppc-softmmu sparc-softmmu x86_64-softmmu"
	export TARGET_LIST
}

pkg_setup() {
	if [ "$(gcc-major-version)" == "4" ]; then
		ewarn "Qemu could not build with GCC 4"
	fi

	MODULE_NAMES="$(useq kqemu && echo "kqemu(misc:${S}/kqemu)")"
	#	$(useq qvm86 && echo "qvm86(misc:${S}/qvm86)")"
	#( use kqemu || use qvm86 ) && linux-mod_pkg_setup
	use kqemu && linux-mod_pkg_setup

	if use kqemu ; then
		einfo "QEMU Accelerator enabled (USE=kqemu)"
		einfo "kqemu is binary module with a restricted license."
		einfo "Please read carefully the KQEMU license"
		einfo "and ${HOMEPAGE}qemu-accel.html"
		einfo "if you would like to see it released under the GPL"
	fi
}

#RUNTIME_PATH="/emul/gnemul/"
src_unpack() {
	unpack ${A}

	if use kqemu; then
		mv ${WORKDIR}/kqemu ${S}
		cd ${S}/kqemu
		sed -i -e 's:#ifndef PAGE_KERNEL_EXEC:#if 1:' ${S}/kqemu/kqemu-linux.c
		# The class_simple interfaces were removed in 2.6.13-rc1, leaving only
		# GPL symbols behind, which this module can't use.  Until there's a fix
		# from Fabrice, kqemu+udev no worky.
		if kernel_is le 2 6 12; then
			epatch ${FILESDIR}/kqemu-${PV}-sysfs.patch
		fi
	fi
	#	if use qvm86; then
#		mv ${WORKDIR}/qvm86 ${S}
#		cd ${S}
#		epatch qvm86/patch.qvm86
#	fi
	cd ${S}
	#Fix errno mismatch on glibc-2.3.5

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
	if ! use sdl ; then
		myconf="$myconf --disable-gfx-check"
	fi
	set_target_list
#		--interp-prefix=${RUNTIME_PATH}/qemu-%M
	./configure \
		--prefix=/usr \
		--target-list="${TARGET_LIST}" \
		--enable-slirp \
		--kernel-path=${KV_DIR} \
		$(use_enable kqemu) \
		${myconf} \
		$(use_enable sdl)\
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

	chmod -x ${D}/usr/share/man/*/*

	if use kqemu ; then

		linux-mod_src_install

		# udev rule
		dodir /etc/udev/rules.d/
		echo 'KERNEL="kqemu*",           NAME="%k", GROUP="qemu", MODE="0660"' \
			> ${D}/etc/udev/rules.d/48-qemu.rules
		enewgroup qemu

		# Module doc
		dodoc ${S}/kqemu/README

	fi
}

pkg_postinst() {
	einfo "You will need the Universal TUN/TAP driver compiled into"
	einfo "kernel or as a module to use the virtual network device."
	if use kqemu ; then
		linux-mod_pkg_postinst
		einfo "Make sure you have the kernel module loaded before running qemu"
		einfo "and your user is in the qemu group"
	fi
}
