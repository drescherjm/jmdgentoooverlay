# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

ETYPE="sources"
UNIPATCH_STRICTORDER="1"
K_WANT_GENPATCHES="base extras"
K_GENPATCHES_VER="10"
inherit kernel-2
detect_version
detect_arch

DESCRIPTION="Full sources for a dom0/domU Linux kernel to run under Xen"
HOMEPAGE="http://www.xensource.com/xen/xen/"

XEN_BASE_KV="2.6.20.12"
SRC_URI="${KERNEL_URI} ${GENPATCHES_URI} ${ARCH_URI}"

UNIPATCH_LIST="${FILESDIR}/${XEN_BASE_KV}/*.patch"

KEYWORDS="~x86 ~amd64"

pkg_postinst() {
	#postinst_sources
	kernel-2_pkg_postinst
	elog "This kernel uses xen patches produced for Fedora Core"
	elog "They have been adapted for Gentoo, but may not work"
}
