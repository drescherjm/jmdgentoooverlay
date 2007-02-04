# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils subversion games

# Doesn't include first 2 digits of year ("20")
MY_PV=${PV:2}

DESCRIPTION="Game engine for Red Alert"
HOMEPAGE="http://www.freera.org/"
SRC_URI="demo? (
		ftp://ftp.westwood.com/pub/redalert/previews/demo/ra95demo.zip
		mirror://3dgamers/ccredalert/ra95demo.zip )"

ESVN_REPO_URI="https://${PN}.svn.sourceforge.net/svnroot/${PN}/${PN}++"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE="demo doc tools"

DEPEND=">=media-libs/libsdl-1.2.8
	>=media-libs/sdl-mixer-1.2.5"

S=${WORKDIR}/${PN}++
dir=${GAMES_DATADIR}/${PN}

src_unpack() {
	[[ -n "${A}" ]] && unpack ${A}
	subversion_src_unpack
	cd "${S}"

	# Remove useless symlinks
	rm -f data/mix/{main,redalert}.mix

	# Use shared directory tree
	sed -i \
		-e "s:binloc = \".\":binloc = \"${dir}\":" \
		src/misc/common.cpp || die

	# Should really write to ~/.freera.log
	sed -i \
		-e "s:lf += \"/freera.log\":lf = \"/tmp/freera.log\":" \
		src/freera.cpp || die

	sed -i \
		-e "s:lf += \"/tmpinied.log\":lf = \"/tmp/tmpinied.log\":" \
		tools/tmpinied/tmpinied.cpp || die

	sed -i \
		-e "s:lf += \"/shpview.log\":lf = \"/tmp/shpview.log\":" \
		tools/shpview/shpview.cpp || die
}

src_install() {
	insinto "${dir}"
	doins -r data || die

	if use demo ; then
		insinto "${dir}"/data/mix
		newins "${WORKDIR}"/ra95demo/INSTALL/MAIN.MIX main.mix || die
		newins "${WORKDIR}"/ra95demo/INSTALL/REDALERT.MIX redalert.mix || die
	fi

	dogamesbin ${PN} || die
	if use tools ; then
		dogamesbin tmpinied shpview || die
	fi

	newicon data/gfx/icon.xpm ${PN}.xpm || die "newicon failed"
	make_desktop_entry ${PN} "FreeRA" ${PN}.xpm

	dodoc *.txt
	if use doc ; then
		dodoc doc/tech/*
	fi

	prepgamesdirs
}

pkg_postinst() {
	games_pkg_postinst

	if ! use demo ; then
		elog "Place main.mix & redalert.mix from either of the 2 Red Alert CDs in:"
		elog " ${dir}/data/mix/"
		echo
	fi
}
