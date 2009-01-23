# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-emulation/virtualbox-modules/virtualbox-modules-2.0.6.ebuild,v 1.1 2008/11/29 20:39:49 vapier Exp $

# XXX: the tarball here is just the kernel modules split out of the binary
#      package that comes from virtualbox-bin

inherit eutils linux-mod

MY_P=vbox-kernel-module-src-${PV}
DESCRIPTION="Kernel Modules for Virtualbox"
HOMEPAGE="http://www.virtualbox.org/"
SRC_URI="http://gentoo.zerodev.it/files/${MY_P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND="!=app-emulation/virtualbox-ose-9999"

S=${WORKDIR}/vboxdrv

BUILD_TARGETS="all"
BUILD_TARGET_ARCH="${ARCH}"
MODULE_NAMES="vboxdrv(misc:${S})"

pkg_setup() {
	linux-mod_pkg_setup
	BUILD_PARAMS="KERN_DIR=${KV_DIR} KERNOUT=${KV_OUT_DIR}"
	enewgroup vboxusers
}

src_install() {
	linux-mod_src_install

	# udev rule for vboxdrv
	dodir /etc/udev/rules.d
	echo 'KERNEL=="vboxdrv", GROUP="vboxusers" MODE=660' >> "${D}/etc/udev/rules.d/60-virtualbox.rules"
}

pkg_postinst() {
	linux-mod_pkg_postinst
}
