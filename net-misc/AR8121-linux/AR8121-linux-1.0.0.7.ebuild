inherit eutils toolchain-funcs linux-mod

MY_PV=${PN}-ver${PV}

DESCRIPTION="kernel driver for Attansic Technology Corp. device 1026 NIC"
HOMEPAGE=""
SRC_URI="${MY_PV}.tar.bz2"

LICENSE=""
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""
RESTRICT="fetch"

DEPEND=""
RDEPEND=""

S=${WORKDIR}/${MY_PV}

src_unpack() {
	if ( kernel_is ge 2 6 27 ); then
	   die "This driver is already in 2.6.27 and greater"
	fi
 	
        unpack ${A}
	
}

src_compile() {
#	cd ${MY_PV}/src
	cd src
        sed -i s/CFLAGS/EXTRA_CFLAGS/g Makefile
#	make install
	make
}

src_install() {
	MODULE_NAMES="atl1e(kernel/drivers/net:${S}/src)"
	linux-mod_src_install
}

