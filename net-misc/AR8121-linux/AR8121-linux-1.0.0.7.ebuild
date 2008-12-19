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
	unpack ${A}
}

src_compile() {
#	cd ${MY_PV}/src
	cd src
#	make install
	make
}

src_install() {
	MODULE_NAMES="atl1e(kernel/drivers/net:${S}/src)"
	linux-mod_src_install
}

