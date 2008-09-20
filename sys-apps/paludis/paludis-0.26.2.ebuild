# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-apps/paludis/paludis-0.26.2.ebuild,v 1.1 2008/05/29 14:11:10 zlin Exp $

inherit bash-completion eutils flag-o-matic

DESCRIPTION="paludis, the other package mangler"
HOMEPAGE="http://paludis.pioto.org/"
SRC_URI="http://paludis.pioto.org/download/${P}.tar.bz2"

IUSE="doc glsa inquisitio portage pink python qa ruby vim-syntax zsh-completion visibility"
LICENSE="GPL-2 vim-syntax? ( vim )"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~s390 ~sparc ~x86"

COMMON_DEPEND="
	>=app-admin/eselect-1.0.2
	>=app-admin/eselect-news-20071201
	>=app-shells/bash-3
	qa? ( dev-libs/pcre++ >=dev-libs/libxml2-2.6 app-crypt/gnupg )
	inquisitio? ( dev-libs/pcre++ )
	glsa? ( >=dev-libs/libxml2-2.6 )
	ruby? ( >=dev-lang/ruby-1.8 )
	python? ( >=dev-lang/python-2.4 >=dev-libs/boost-1.33.1-r1 )
	virtual/c++-tr1-functional
	virtual/c++-tr1-memory
	virtual/c++-tr1-type-traits"

DEPEND="${COMMON_DEPEND}
	doc? (
		|| ( >=app-doc/doxygen-1.5.3 <=app-doc/doxygen-1.5.1 )
		media-gfx/imagemagick
	)
	python? ( dev-python/epydoc dev-python/pygments )
	ruby? ( doc? ( dev-ruby/syntax dev-ruby/allison ) )
	dev-util/pkgconfig"

RDEPEND="${COMMON_DEPEND}
	net-misc/wget
	net-misc/rsync
	sys-apps/sandbox"

# Keep this as a PDEPEND. It avoids issues when Paludis is used as the
# default virtual/portage provider.
PDEPEND="
	vim-syntax? ( >=app-editors/vim-core-7 )"

PROVIDE="virtual/portage"

pkg_setup() {
	replace-flags -Os -O2
	replace-flags -O3 -O2

	enewgroup "paludisbuild"
	enewuser "paludisbuild" "-1" "-1" "/var/tmp/paludis" "paludisbuild"

#	FIXED_MAKEOPTS=""
#	m=$(free -m | sed -n -e '/cache:/s,^[^[:digit:]]\+[[:digit:]]\+[^[:digit:]]\+\([[:digit:]]\+\).*,\1,p')
#	j=$(echo "$MAKEOPTS" | sed -n -e 's,.*-j\([[:digit:]]\+\).*,\1,p' )
#	if [[ -n "${m}" ]] && [[ -n "${j}" ]] && (( ${j} > 1 )); then
#		if (( m < j * 512 )) ; then
#			FIXED_MAKEOPTS="-j$(( m / 512 ))"
#			[[ ${FIXED_MAKEOPTS} == "-j0" ]] && FIXED_MAKEOPTS="-j1"
#			ewarn "Your MAKEOPTS -j is too high. To stop the kernel from throwing a hissy fit"
#			ewarn "when g++ eats all your RAM, we'll use ${FIXED_MAKEOPTS} instead."
#		fi
#	fi
}

src_compile() {
	local repositories=`echo default unpackaged | tr -s \  ,`
	local clients=`echo default accerso adjutrix contrarius importare \
		$(usev inquisitio ) instruo paludis reconcilio | tr -s \  ,`
	local environments=`echo default $(usev portage ) | tr -s \  ,`
	econf \
		$(use_enable doc doxygen ) \
		$(use_enable pink ) \
		$(use_enable qa ) \
		$(use_enable ruby ) \
		$(useq ruby && useq doc && echo --enable-ruby-doc ) \
		$(use_enable python ) \
		$(use_enable glsa ) \
		$(use_enable vim-syntax vim ) \
		$(use_enable visibility ) \
		--with-vim-install-dir=/usr/share/vim/vimfiles \
		--enable-sandbox \
		--with-repositories=${repositories} \
		--with-clients=${clients} \
		--with-environments=${environments} \
		|| die "econf failed"

	emake ${FIXED_MAKEOPTS} || die "emake failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "install failed"
	dodoc AUTHORS README ChangeLog NEWS

	BASH_COMPLETION_NAME="adjutrix" dobashcompletion bash-completion/adjutrix
	BASH_COMPLETION_NAME="paludis" dobashcompletion bash-completion/paludis
	BASH_COMPLETION_NAME="accerso" dobashcompletion bash-completion/accerso
	BASH_COMPLETION_NAME="contrarius" dobashcompletion bash-completion/contrarius
	BASH_COMPLETION_NAME="importare" dobashcompletion bash-completion/importare
	BASH_COMPLETION_NAME="instruo" dobashcompletion bash-completion/instruo
	BASH_COMPLETION_NAME="reconcilio" dobashcompletion bash-completion/reconcilio
	use qa && \
		BASH_COMPLETION_NAME="qualudis" \
		dobashcompletion bash-completion/qualudis
	use inquisitio && \
		BASH_COMPLETION_NAME="inquisitio" \
		dobashcompletion bash-completion/inquisitio

	if use zsh-completion ; then
		insinto /usr/share/zsh/site-functions
		doins zsh-completion/_paludis
		doins zsh-completion/_adjutrix
		doins zsh-completion/_importare
		doins zsh-completion/_reconcilio
		use inquisitio && doins zsh-completion/_inquisitio
		doins zsh-completion/_paludis_packages
	fi
}

src_test() {
	# Work around Portage bugs
	export PALUDIS_DO_NOTHING_SANDBOXY="portage sucks"
	export BASH_ENV=/dev/null

	emake check || die "Make check failed"
}

pkg_postinst() {
	# Remove the symlink created by app-admin/eselect-news
	if [[ -L "${ROOT}/var/lib/paludis/news" ]] ; then
		rm "${ROOT}/var/lib/paludis/news"
	fi
}
