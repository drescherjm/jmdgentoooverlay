EAPI=7

inherit git-r3

if [ "${PV}" = "9999" ]; then
        EGIT_REPO_URI="http://github.com/drescherjm/btrfs-snapshot-rotation.git"
        KEYWORDS=""
        inherit git-r3
else
        SRC_URI="https://github.com/drescherjm/btrfs-snapshot-rotation/archive/1.0.0.zip"
fi



#MY_PV="${PV/_rc/rc}"
#MY_P="${PN#nagios-}_v${MY_PV}"

DESCRIPTION="A script to manage and rotate btrfs snapshots"
HOMEPAGE="https://github.com/drescherjm/btrfs-snapshot-rotation"
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
	doexe btrfs-snapshot
}

