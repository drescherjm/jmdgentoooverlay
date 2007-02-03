# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

MY_PV="${PV//./}jo"
MY_P="${PN}-${MY_PV}"
DESCRIPTION="WineTools is a menu-driven tool for installing Windows programs under wine."
HOMEPAGE="http://www.von-thadden.de/Joachim/WineTools/"
SRC_URI="http://ds80-237-203-29.dedicated.hosteurope.de/wt/${MY_P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86"

IUSE=""
RDEPEND=">=app-emulation/wine-20040914
	sys-devel/gettext
	x11-misc/xdialog
	dev-lang/perl"

S="${WORKDIR}/${MY_P}"
INSTALLDIR="/opt/winetools"
LOCALEDIR="/usr/share/locale"
WT=wt${MY_PV}

src_unpack() {
	unpack ${A}
	cd ${S}
	sed -i -e "s:/usr/local/winetools:${INSTALLDIR}:g"   \
	       -e "s:/usr/local/share/locale:${LOCALEDIR}:g" \
		   -e 's:^DIALOG=.*:DIALOG=$(which Xdialog):'    \
		   ${WT} findwine || die "sed failed"
}

src_compile() {
	true
}

src_install() {

	rm -f install Xdialog gettext.* winetools.spec

	dodir ${INSTALLDIR}/doc
	insinto ${INSTALLDIR}/doc
	doins doc/README.* || die "doins failed"
	rm -f doc/README.*

	HTMLFILES="doc/*.html doc/*.gif"
	dohtml ${HTMLFILES} || die "dohtml failed"
	rm ${HTMLFILES}
	DOCFILES="LICENSE.txt INSTALL.txt"
	dodoc ${DOCFILES} doc/* || die "dodoc failed"
	rm -f ${DOCFILES}

	for i in $(ls po/*.po|cut -f1 -d.); do
		LCDIR="${LOCALEDIR}/${i}/LC_MESSAGES"
		dodir "${LCDIR}"
		msgfmt ${i}.po -o "${D}/${LCDIR}/wt2.mo"
	done

	diropts -m0755
	insinto ${INSTALLDIR}
	doins * || die "doins failed"

	exeinto ${INSTALLDIR}
	doexe ${WT} findwine chopctrl.pl listit || die "doexe failed"

	dodir ${INSTALLDIR}/icon
	insinto ${INSTALLDIR}/icon
	doins icon/*

	cd scripts
	SCRIPTLINKS=""
	for file in *; do
		if [[ -h $file ]]; then
			SCRIPTLINKS="${SCRIPTLINKS} dosym $(readlink $file) ${INSTALLDIR}/scripts/$file;"
			rm -f $file
		fi
	done
	cd ..

	dodir ${INSTALLDIR}/scripts
	exeinto ${INSTALLDIR}/scripts
	doexe scripts/*
	eval "${SCRIPTLINKS}"

	dodir /usr/bin
	cd ${D}/usr/bin
	dosym ../..${INSTALLDIR}/${WT}    /usr/bin/wt2
	dosym ../..${INSTALLDIR}/${WT}    /usr/bin/winetools
	dosym ../..${INSTALLDIR}/findwine /usr/bin/findwine
}

pkg_postinst() {
	einfo "*****************************************************************"
	einfo "Start WineTools as *normal* user with \"wt2\". Don't use as root!"
	einfo "*****************************************************************"
}
