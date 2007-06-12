# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-emulation/xen/xen-3.0.4_p1.ebuild,v 1.1 2007/05/02 04:27:24 marineam Exp $

inherit mount-boot flag-o-matic

DESCRIPTION="The Xen virtual machine monitor"
HOMEPAGE="http://www.xensource.com/xen/xen/"
MY_PV=${PV/_p/_}
SRC_URI="http://bits.xensource.com/oss-xen/release/${MY_PV/_/-}/src.tgz/xen-${MY_PV}-src.tgz"
S="${WORKDIR}/xen-${MY_PV}-src"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="debug custom-cflags pae"

RDEPEND="|| ( sys-boot/grub
		sys-boot/grub-static )
		>=sys-kernel/xen-sources-2.6.16.33"
PDEPEND="~app-emulation/xen-tools-${PV}"

RESTRICT="test"

# Approved by QA team in bug #144032
QA_WX_LOAD="boot/xen-syms-${MY_PV/_/-}"

pkg_setup() {
	if [[ -z ${XEN_TARGET_ARCH} ]]; then
		if use x86; then
			export XEN_TARGET_ARCH="x86_32"
		elif use amd64; then
			export XEN_TARGET_ARCH="x86_64"
		else
			die "Unsupported architecture!"
		fi
	fi
}

src_unpack() {
	unpack ${A}
	# if the user *really* wants to use their own custom-cflags, let them
	if use custom-cflags; then
		einfo "User wants their own CFLAGS - removing defaults"
		# try and remove all the default custom-cflags
		find "${S}" -name Makefile -o -name Rules.mk -o -name Config.mk -exec sed \
			-e 's/CFLAGS\(.*\)=\(.*\)-O3\(.*\)/CFLAGS\1=\2\3/' \
			-e 's/CFLAGS\(.*\)=\(.*\)-march=i686\(.*\)/CFLAGS\1=\2\3/' \
			-e 's/CFLAGS\(.*\)=\(.*\)-fomit-frame-pointer\(.*\)/CFLAGS\1=\2\3/' \
			-e 's/CFLAGS\(.*\)=\(.*\)-g3*\s\(.*\)/CFLAGS\1=\2 \3/' \
			-e 's/CFLAGS\(.*\)=\(.*\)-O2\(.*\)/CFLAGS\1=\2\3/' \
			-i {} \;
	fi

	# xen tries to be smart and filter out CFLAGs not supported by gcc.
	# It doesn't handle no* flags though, but flag-o-matic's test-flag-CC does.
	for FLAG in -nopie -fno-stack-protector -fno-stack-protector-all; do
		test-flag-CC ${FLAG} && HARDFLAGS="${HARDFLAGS} ${FLAG}"
	done
	sed  -i "s/^CFLAGS-y.*__XEN__.*$/& ${HARDFLAGS}/" \
		"${S}"/xen/Rules.mk
}

src_compile() {
	local myopt
	use debug && myopt="${myopt} debug=y"
	use pae && myopt="${myopt} pae=y"

	if use custom-cflags; then
		filter-flags -fPIE -fstack-protector
	else
		unset CFLAGS
	fi

	# Send raw LDFLAGS so that --as-needed works
	emake LDFLAGS="$(raw-ldflags)" -C xen ${myopt} || die "compile failed"
}

src_install() {
	local myopt
	use debug && myopt="${myopt} debug=y"
	use pae && myopt="${myopt} pae=y"

	make DESTDIR="${D}" ${myopt} install-xen || die "install failed"
}

pkg_postinst() {
	elog "Please visit the Xen and Gentoo wiki:"
	elog "http://gentoo-wiki.com/HOWTO_Xen_and_Gentoo"

	echo
	elog "Note: xen tools have been moved to app-emulation/xen-tools"

	if use pae; then
		echo
		ewarn "This is a PAE build of Xen. It will *only* boot PAE kernels!"
	fi
}
