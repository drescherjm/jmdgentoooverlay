# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-kernel/openvz-sources/openvz-sources-2.6.18.028.049.ebuild,v 1.2 2007/11/20 06:35:32 pva Exp $

inherit versionator

ETYPE="sources"
CKV=$(get_version_component_range 1-3)
OVZ_KERNEL="$(get_version_component_range 4)"
OVZ_REV="1"

inherit kernel-2
detect_version
EXTRAVERSION=-${OVZ_KERNEL}
KV_FULL=${CKV}-${PN/-*}-$(get_version_component_range 4)

KEYWORDS="amd64 ~ia64 ~ppc64 ~sparc x86"
IUSE=""

DESCRIPTION="Full sources including OpenVZ patchset for the ${KV_MAJOR}.${KV_MINOR} kernel tree"
HOMEPAGE="http://www.openvz.org"
SRC_URI="${KERNEL_URI} ${ARCH_URI}
	http://download.openvz.org/kernel/branches/${CKV}/${CKV}-ovz${OVZ_KERNEL}.${OVZ_REV}/patches/patch-ovz${OVZ_KERNEL}.${OVZ_REV}-combined.gz"

UNIPATCH_STRICTORDER=1
UNIPATCH_LIST="${DISTDIR}/patch-ovz${OVZ_KERNEL}.${OVZ_REV}-combined.gz"
