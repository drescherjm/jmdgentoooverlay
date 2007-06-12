# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-emulation/xen-tools/xen-tools-3.0.4_p1.ebuild,v 1.2 2007/05/16 00:57:34 marineam Exp $

inherit flag-o-matic distutils eutils multilib

DESCRIPTION="Xend daemon and tools"
HOMEPAGE="http://www.xensource.com/xen/xen/"
MY_PV=${PV/_p/_}
SRC_URI="http://bits.xensource.com/oss-xen/release/${MY_PV/_/-}/src.tgz/xen-${MY_PV}-src.tgz"
S="${WORKDIR}/xen-${MY_PV}-src"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="doc debug screen custom-cflags pygrub ioemu"

CDEPEND="dev-lang/python
	sys-libs/zlib
	ioemu? ( media-libs/libsdl )"

DEPEND="${CDEPEND}
	sys-devel/gcc
	dev-lang/perl
	sys-devel/dev86
	app-misc/pax-utils
	doc? (
		dev-tex/latex2html
		media-gfx/transfig
	)
	ioemu? (
		x11-proto/xproto
		net-libs/libvncserver
	)"

RDEPEND="${CDEPEND}
	sys-apps/iproute2
	net-misc/bridge-utils
	screen? (
		app-misc/screen
		app-admin/logrotate
	)
	|| ( sys-fs/udev sys-apps/hotplug )"

PYTHON_MODNAME="xen grub"

# hvmloader is used to bootstrap a fully virtualized kernel
# Approved by QA team in bug #144032
QA_WX_LOAD="usr/lib/xen/boot/hvmloader"

pkg_setup() {
	if [[ "$(scanelf -s __guard -q `which python`)" ]] ; then
		ewarn "xend may not work when python is built with stack smashing protection (ssp)."
		ewarn "If 'xm create' fails with '<ProtocolError for /RPC2: -1 >', see bug #141866"
	fi

	if [[ -z ${XEN_TARGET_ARCH} ]] ; then
		if use x86 ; then
			export XEN_TARGET_ARCH="x86_32"
		elif use amd64 ; then
			export XEN_TARGET_ARCH="x86_64"
		else
			die "Unsupported architecture!"
		fi
	fi
}

src_unpack() {
	unpack ${A}
	cd "${S}"

	epatch "${FILESDIR}/python-path.patch"

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
	sed  -i "s/^CFLAGS :=$/& ${HARDFLAGS}/" \
		"${S}"/tools/firmware/{hvmloader,vmxassist}/Makefile


	# Disable the 32bit-only vmxassist if we are not on x86 and we don't
	# support the x86 ABI. Also disable hvmloader, since it requires vmxassist.
	if ! use x86 && ! has x86 $(get_all_abis); then
		sed -i -e "/SUBDIRS += vmxassist/d" "${S}"/tools/firmware/Makefile
		sed -i -e "/SUBDIRS += hvmloader/d" "${S}"/tools/firmware/Makefile
	fi

	if ! use pygrub; then
		sed -i -e "/^SUBDIRS-y += pygrub$/d" "${S}"/tools/Makefile
	fi

	# Don't bother with ioemu, only needed for fully virtualised guests
	if ! use ioemu; then
		chmod 644 tools/check/check_x11_devel
		sed -i -e "/^CONFIG_IOEMU := y$/d" "${S}"/config/*.mk
	fi
}

src_compile() {
	local myopt myconf
	use debug && myopt="${myopt} debug=y"

	use custom-cflags || unset CFLAGS
	gcc-specs-ssp && append-flags -fno-stack-protector -fno-stack-protector-all

	if use ioemu; then
		myconf="${myconf} --disable-system --disable-user"
		(cd tools/ioemu && econf ${myconf}) || die "configure failured"
	fi

	emake -C tools ${myopt} || die "compile failed"

	if use doc; then
		sh ./docs/check_pkgs || die "package check failed"
		emake -C docs || die "compiling docs failed"
	fi

	emake -C docs man-pages || die "make man-pages failed"
}

src_install() {
	local myopt="XEN_PYTHON_NATIVE_INSTALL=1"

	make DESTDIR="${D}" ${myopt} install-tools \
		|| die "install failed"

	# Remove RedHat-specific stuff
	rm -rf "${D}"/etc/sysconfig

	if use doc; then
		make DESTDIR="${D}" -C docs install || die "install docs failed"
		# Rename doc/xen to the Gentoo-style doc/xen-x.y
		mv "${D}"/usr/share/doc/{${PN},${PF}}
	fi

	doman docs/man?/*

	newinitd "${FILESDIR}"/xend.initd xend \
		|| die "Couldn't install xen.initd"
	newconfd "${FILESDIR}"/xendomains.confd xendomains \
		|| die "Couldn't install xendomains.confd"
	newinitd "${FILESDIR}"/xendomains.initd xendomains \
		|| die "Couldn't install xendomains.initd"

	if use screen; then
		cat "${FILESDIR}"/xendomains-screen.confd >> "${D}"/etc/conf.d/xendomains
		cp "${FILESDIR}"/xen-consoles.logrotate "${D}"/etc/xen/
		keepdir /var/log/xen-consoles
	fi

	# xend expects these to exist
	keepdir /var/run/xenstored /var/lib/xenstored /var/xen/dump /var/lib/xen /var/log/xen
}

pkg_postinst() {
	elog "Please visit the Xen and Gentoo wiki:"
	elog "http://gentoo-wiki.com/HOWTO_Xen_and_Gentoo"

	if ! built_with_use dev-lang/python ncurses; then
		echo
		ewarn "NB: Your dev-lang/python is built without USE=ncurses."
		ewarn "Please rebuild python with USE=ncurses to make use of xenmon.py."
	fi

	if grep -qsF XENSV= "${ROOT}/etc/conf.d/xend"; then
		echo
		elog "xensv is broken upstream (Gentoo bug #142011)."
		elog "Please remove '${ROOT%/}/etc/conf.d/xend', as it is no longer needed."
	fi
}
