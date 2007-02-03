# Copyright 1999-2004 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

UNIPATCH_LIST="${DISTDIR}/patch-${KV}.bz2"
K_PREPATCHED="yes"
UNIPATCH_STRICTORDER="yes"

K_NOUSENAME="yes"
ETYPE="sources"
inherit kernel-2
detect_version
IUSE=""

DESCRIPTION="Full sources for the Stock Linux kernel and some various patches to improve desktop performance"
HOMEPAGE="http://sepi.be/nitro/"
SRC_URI="${KERNEL_URI} http://sepi.be/nitro/${KV}/patch-${KV}.bz2"

KEYWORDS="~x86"

pkg_postinst() {
	postinst_sources

   ewarn "IMPORTANT:"
	ewarn "This is a experimental kernel version, I'm not responsible for breaking your system"
	ewarn "Just remember that nitro-sources is unstable but very fast!!"
	echo
	ewarn "Now compile this beauty, reboot, and fasten your seatbelts!"
   echo
}
