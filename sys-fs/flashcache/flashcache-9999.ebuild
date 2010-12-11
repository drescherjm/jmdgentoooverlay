EAPI="2"

inherit eutils git linux-mod

EGIT_REPO_URI="git://github.com/facebook/flashcache.git"
KEYWORDS="~amd64 ~x86"

DESCRIPTION="FlashCache provides a way to use a SSD as a cache for slower disks"
HOMEPAGE="http://www.github.com/facebook/flashcache"

LICENSE="GPL-2"
SLOT="0"
IUSE=""

MODULE_NAMES="flashcache(misc:${S}/src)"
RDEPEND="dev-vcs/git"
DEPEND="${RDEPEND}"

src_unpack() {
   git_src_unpack
   cd "${S}"
#   epatch ${FILESDIR}/flashcache-2.6.36-rw_barrier.patch  
}

src_compile() {
    ARCH=x86
    MAKEOPTS="-j1"
    emake CC=$(tc-getCC) KERNEL_TREE="${KV_DIR}" || die
}

src_install() {
    docinto
    dodoc README || die
    dodoc  ${S}/doc/flashcache-sa-guide.txt ${S}/doc/flashcache-doc.txt
    linux-mod_src_install
    dosbin "${S}/src/utils/flashcache_create" || die "install failed"
    dosbin "${S}/src/utils/flashcache_destroy" || die "install failed"
    dosbin "${S}/src/utils/flashcache_load" || die "install failed"
}

