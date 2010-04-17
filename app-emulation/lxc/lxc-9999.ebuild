# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

inherit autotools eutils linux-info git

DESCRIPTION="LinuX Containers userspace utilities"
HOMEPAGE="http://lxc.sourceforge.net/"
EGIT_REPO_URI="git://lxc.git.sourceforge.net/gitroot/lxc/lxc"

LICENSE="LGPL-3"
SLOT="0"
KEYWORDS=""
IUSE="doc examples extra"

RDEPEND="
	sys-libs/libcap
	>=sys-kernel/linux-headers-2.6.29
"
DEPEND="
	doc? ( app-text/docbook-sgml-utils )
	${RDEPEND}
"

CONFIG_CHECK="CGROUPS
	CGROUP_NS CPUSETS CGROUP_CPUACCT
	RESOURCE_COUNTERS CGROUP_MEM_RES_CTLR
	CGROUP_SCHED

	NAMESPACES
	IPC_NS USER_NS PID_NS"

SUPPLIMENTARY_KOPTIONS="
	DEVPTS_MULTIPLE_INSTANCES
	CGROUP_FREEZER
	UTS_NS NET_NS
	VETH MACVLAN
"

INFO_DEVPTS_MULTIPLE_INSTANCES="Required for pts inside container"

INFO_CGROUP_FREEZER="Required to freeze containers"

INFO_UTS_NS="Required to unshare hostnames and uname info"
INFO_NET_NS="Required for unshared network"

INFO_VETH="Required for internal (inter-container) networking"
INFO_MACVLAN="${INFO_VETH}"

src_prepare() {
	if use extra; then
		ewarn "You've enabled extra patches, which are currently"
		ewarn "UNSUPPORTED by upstream. If you experiesing any problems"
		ewarn "try to turn them off before bug reporting"

		epatch "${FILESDIR}"/9999-extra/*
	fi

	epatch_user

	eautoreconf
}

src_configure() {
	econf \
		--localstatedir=/var				\
		--bindir=/usr/sbin					\
		--docdir='${datadir}'/doc/${P}		\
		--with-config-path=/etc/lxc			\
		$(use_enable doc)					\
		$(use_enable examples)				\
		|| die "configure failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "install failed"

	dodoc AUTHORS CONTRIBUTING MAINTAINERS	|| die "dodoc failed"
	dodoc NEWS TODO README doc/FAQ.txt		|| die "dodoc failed"

	rm -Rf "${D}"/etc/lxc
	rm -f "${D}"/usr/sbin/lxc-{setcap,ls}

	keepdir /etc/lxc

	find "${D}" -name '*.la' -delete

	newinitd "${FILESDIR}"/lxc.initd lxc
}

pkg_postinst() {
	local warn_about= option= message=

	for option in ${SUPPLIMENTARY_KOPTIONS}; do
		linux_chkconfig_present ${option} && continue;

		warn_about="${warn_about} ${option}"
	done

	if [[ -n "${warn_about}" ]]; then
		elog "There is few kernel options that is not mandatory for LXC"
		elog "But some nice features will refuse to work without them"
		elog "Here comes a list of options you may be interested to add:"
		elog

		for option in ${warn_about}; do
			eval message=\${INFO_${option}}

			elog "\tCONFIG_${option}: ${message}"
		done
	fi
}
