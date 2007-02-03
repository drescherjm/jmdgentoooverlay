# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

ETYPE="sources"
K_WANT_GENPATCHES="base"
K_GENPATCHES_VER="6"

inherit kernel-2
detect_version

UNIPATCH_LIST="${DISTDIR}/${P}.patch.bz2"
DESCRIPTION="Xen sources for the ${KV_MAJOR}.${KV_MINOR} kernel tree"
XEN_URI="http://dev.gentoo.org/~aross/${P}.patch.bz2"
SRC_URI="${KERNEL_URI} ${GENPATCHES_URI} ${ARCH_URI} ${XEN_URI}"
KEYWORDS="~amd64 ~x86"
