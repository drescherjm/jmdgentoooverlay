EAPI=7

inherit git-r3

if [ "${PV}" = "9999" ]; then
        EGIT_REPO_URI="https://github.com/agronick/btrfs-size.git"
        KEYWORDS=""
        inherit git-r3
#else
#        SRC_URI="https://github.com/drescherjm/btrfs-snapshot-rotation/archive/1.0.0.zip"
fi



#MY_PV="${PV/_rc/rc}"
#MY_P="${PN#nagios-}_v${MY_PV}"

DESCRIPTION="A script that will print out a list of BTRFS subvolumes along with their size."
HOMEPAGE="https://github.com/drescherjm/btrfs-size"
SRC_URI=""

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE=""

DEPEND=""
RDEPEND="sys-fs/btrfs-progs"

S="${WORKDIR}/${MY_P}"

src_install() {
	exeinto /usr/bin
	doexe btrfs-size.sh
}

