# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-emulation/lxc/lxc-0.8.0-r1.ebuild,v 1.2 2013/05/04 21:42:25 jlec Exp $

EAPI="5"
PYTHON_COMPAT=( python{3_1,3_2,3_3} )

AUTOTOOLS_AUTORECONF=true
AUTOTOOLS_IN_SOURCE_BUILD=1

inherit autotools-utils eutils flag-o-matic linux-info versionator distutils-r1

DESCRIPTION="LinuX Containers userspace utilities"
HOMEPAGE="http://linuxcontainers.org/"

if [[ "${PV}" == "9999" ]]; then
    inherit git-2
    EGIT_REPO_URI="https://github.com/lxc/lxc.git"
	SRC_URI=""
	S="${WORKDIR}/lxc-master"
else
	SRC_URI="https://github.com/lxc/lxc/archive/${P}.tar.gz"
fi

[[ "${PV}" == "0.9.0" ]] && use_usleep="sys-apps/usleep"

S="${WORKDIR}/lxc-${P}"

KEYWORDS="~amd64 ~arm ~ppc64 ~x86"

LICENSE="LGPL-3"
SLOT="0"
IUSE="doc examples +lua +python seccomp"

RDEPEND="
	lua? ( >=dev-lang/lua-5.1 
			dev-lua/luafilesystem 
			dev-lua/alt-getopt
			${use_usleep}
			)
	python? ( >=dev-lang/python-3 )
	sys-libs/libcap
	net-libs/gnutls
	seccomp? ( sys-libs/libseccomp[static-libs] )"

DEPEND="${RDEPEND}
	doc? ( app-text/docbook2X )
	>=sys-kernel/linux-headers-3.2"

RDEPEND="${RDEPEND}
	app-misc/pax-utils
	sys-apps/openrc
	sys-apps/util-linux
	virtual/awk"

CONFIG_CHECK="~CGROUPS ~CGROUP_DEVICE
	~CPUSETS ~CGROUP_CPUACCT
	~RESOURCE_COUNTERS
	~CGROUP_SCHED

	~NAMESPACES
	~IPC_NS ~USER_NS ~PID_NS

	~DEVPTS_MULTIPLE_INSTANCES
	~CGROUP_FREEZER
	~UTS_NS ~NET_NS
	~VETH ~MACVLAN

	~POSIX_MQUEUE
	~!NETPRIO_CGROUP

	~!GRKERNSEC_CHROOT_MOUNT
	~!GRKERNSEC_CHROOT_DOUBLE
	~!GRKERNSEC_CHROOT_PIVOT
	~!GRKERNSEC_CHROOT_CHMOD
	~!GRKERNSEC_CHROOT_CAPS
"

ERROR_DEVPTS_MULTIPLE_INSTANCES="CONFIG_DEVPTS_MULTIPLE_INSTANCES:	needed for pts inside container"

ERROR_CGROUP_FREEZER="CONFIG_CGROUP_FREEZER:	needed to freeze containers"

ERROR_UTS_NS="CONFIG_UTS_NS:	needed to unshare hostnames and uname info"
ERROR_NET_NS="CONFIG_NET_NS:	needed for unshared network"

ERROR_VETH="CONFIG_VETH:	needed for internal (host-to-container) networking"
ERROR_MACVLAN="CONFIG_MACVLAN:	needed for internal (inter-container) networking"

ERROR_POSIX_MQUEUE="CONFIG_POSIX_MQUEUE:	needed for lxc-execute command"

#Is this true anymore ?
ERROR_NETPRIO_CGROUP="CONFIG_NETPRIO_CGROUP:	as of kernel 3.3 and lxc 0.8.0_rc1 this causes LXCs to fail booting."

ERROR_GRKERNSEC_CHROOT_MOUNT=":CONFIG_GRKERNSEC_CHROOT_MOUNT	some GRSEC features make LXC unusable see postinst notes"
ERROR_GRKERNSEC_CHROOT_DOUBLE=":CONFIG_GRKERNSEC_CHROOT_DOUBLE	some GRSEC features make LXC unusable see postinst notes"
ERROR_GRKERNSEC_CHROOT_PIVOT=":CONFIG_GRKERNSEC_CHROOT_PIVOT	some GRSEC features make LXC unusable see postinst notes"
ERROR_GRKERNSEC_CHROOT_CHMOD=":CONFIG_GRKERNSEC_CHROOT_CHMOD	some GRSEC features make LXC unusable see postinst notes"
ERROR_GRKERNSEC_CHROOT_CAPS=":CONFIG_GRKERNSEC_CHROOT_CAPS	some GRSEC features make LXC unusable see postinst notes"
ERROR_GRKERNSEC_CHROOT_MKNOD=":CONFIG_GRKERNSEC_CHROOT_MKNOD	some GRSEC features make LXC unusable see postinst notes"

DOCS=(AUTHORS CONTRIBUTING MAINTAINERS TODO README doc/FAQ.txt)

src_prepare() {
	#Patch if any
	for patch_file in $(ls ${FILESDIR}/${P}-*.patch 2>/dev/null); do
		epatch "${patch_file}"
	done

	# prepare python
	if use python; then
		#First we need one python impl to pass the configure
		echo_epython() {
		    echo ${EPYTHON}
		}
		ONEPYTHON=$(python_foreach_impl echo_epython | \
						tail -n1 | \
						sed "s,python,python-,g")
		sed -i "s,python3,${ONEPYTHON}," configure.ac || die
		#Disable python management by Makefile
		echo > src/python-lxc/Makefile.am
	fi

	sed -i 's,docbook2x-man,docbook2man.pl,' configure.ac || die

	autotools-utils_src_prepare
}

src_configure() {
	append-flags -fno-strict-aliasing

	econf \
		--localstatedir=/var \
		--bindir=/usr/sbin \
		--docdir=/usr/share/doc/${PF} \
		--with-config-path=/var/lib/lxc	\
		--with-rootfs-path=/usr/lib/lxc/rootfs \
		$(use_enable doc) \
		$(use_enable seccomp) \
		--disable-apparmor \
		$(use_enable examples) \
		$(use_enable lua) \
		$(use_enable python)
}

src_compile() {
	default

	if use python
	then
	  (
	    cd "${S}/src/python-lxc"
	    python_foreach_impl distutils-r1_python_compile build_ext -I ../ -L ../lxc
	  )
	fi
}

src_install() {
	default

	if use python
	then
		cd "${S}/src/python-lxc"
		echo ${BUILD_DIR}
		python_foreach_impl distutils-r1_python_install
	fi

	keepdir /etc/lxc /usr/lib/lxc/rootfs /var/log/lxc

	find "${D}" -name '*.la' -delete

	# Gentoo's init script
	newinitd "${FILESDIR}/${PN}.initd.2" ${PN}
}

pkg_postinst() {
	elog "There is an init script provided with the package now; no documentation"
	elog "is currently available though, so please check out /etc/init.d/lxc ."
	elog "You _should_ only need to symlink it to /etc/init.d/lxc.configname"
	elog "to start the container defined into /etc/lxc/configname.conf ."
	elog "For further information about LXC development see"
	elog "http://blog.flameeyes.eu/tag/lxc" # remove once proper doc is available
	elog ""
	elog "To use the Fedora, Debian and (various) Ubuntu auto-configuration scripts, you"
	elog "will need sys-apps/yum or dev-util/debootstrap."
	elog ""
	ewarn "Some GrSecurity settings in relation to chroot security will cause LXC not to"
	ewarn "work, while others will actually make it much more secure. Please refer to"
	ewarn "Diego Elio Pettenò's weblog at http://blog.flameeyes.eu/tag/lxc for further"
	ewarn "details."
}

