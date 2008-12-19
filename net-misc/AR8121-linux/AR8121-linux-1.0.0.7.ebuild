inherit eutils toolchain-funcs linux-mod

MY_PV=${PN}-ver${PV}

DESCRIPTION="kernel drivers for atl1e NIC"
HOMEPAGE=""
SRC_URI="${MY_PV}.tar.bz2"

LICENSE=""
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""
RESTRICT="fetch"

DEPEND=""
RDEPEND=""

S=${WORKDIR}/ixp400_xscale_sw

src_unpack() {
	unpack ${A}
}

src_compile() {
	cd ${MY_PV}/src
	make install
}

src_install() {
	MODULE_NAMES="atl1e(kernel/drivers/net:${S})"
	linux-mod_src_install
}

