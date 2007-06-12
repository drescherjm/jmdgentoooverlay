# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

ETYPE="sources"

inherit kernel-2
detect_arch
detect_version

XEN_VERSION="3.1.0"
XEN_PKV="2.6.18"

XEN_DIR="xen-${XEN_VERSION}-src"
XEN_FILE="${XEN_DIR}.tgz"

DESCRIPTION="Full sources for a dom0/domU Linux kernel to run under Xen"
HOMEPAGE="http://www.cl.cam.ac.uk/Research/SRG/netos/xen/index.html"
SRC_URI="${KERNEL_URI} http://bits.xensource.com/oss-xen/release/${XEN_VERSION}/src.tgz/${XEN_FILE}"

KEYWORDS="~x86 ~amd64"
#RDEPEND="~app-emulation/xen-${XEN_VERSION}"
RESTRICT="nostrip"



src_unpack() {

	unpack "$XEN_FILE"

	#call unpack of kernel-2.eclass
	kernel-2_src_unpack || die

	cd "${WORKDIR}/${XEN_DIR}"
	sed -e 's:relative_lndir \([^(].*\):cp -dpPR \1/* .:' \
		-i linux-2.6-xen-sparse/mkbuildtree || die

	# No need to run oldconfig
	sed -e 's:$(MAKE) -C $(LINUX_DIR) ARCH=$(LINUX_ARCH) oldconfig::' \
		-i buildconfigs/mk.linux-2.6-xen || die

	# Move the kernel sources to pristine-linux-${PV}
	mv "${WORKDIR}/linux-${KV}" "pristine-linux-${PV}" || die
	touch "pristine-linux-${PV}/.valid-pristine" || die

	# debugging
	#echo "make LINUX_SRC_PATH=${DISTDIR} XEN_ROOT=${WORKDIR}/${MY_P} 
	#	-f buildconfigs/mk.linux-2.6-xen
	#	linux-${PV}-xen/include/linux/autoconf.h || die"

	#sed -e "s/2.6.16.33/2.6.16.38/" -i buildconfigs/mk.linux-2.6-xen
	if [ "$PV" != "${XEN_PKV}" ]; then
		mv "patches/linux-${XEN_PKV}" "patches/linux-${PV}" || die
	fi

	make LINUX_VER="$PV" XEN_ROOT="${WORKDIR}/${XEN_DIR}" \
		-f buildconfigs/mk.linux-2.6-xen \
		prep || die

	#remove $(XENGUEST) from EXTRAVERSION
	sed -e 's:^\(EXTRAVERSION =.*\)..XENGUEST.:\1:' \
		-i "linux-${PV}-xen/Makefile" || die

	mv "linux-${PV}-xen" "${WORKDIR}/linux-${KV}" || die
	rm -rf "${WORKDIR}/${XEN_DIR}" || die
}
