# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/games-strategy/triplea/triplea-0.6.0.1.ebuild,v 1.6 2005/11/21 21:42:12 blubb Exp $

inherit eutils java-utils java-pkg games

MY_PV=${PV//\./_}
DESCRIPTION="An open source clone of the popular Axis and Allies boardgame"
HOMEPAGE="http://triplea.sf.net"
SRC_URI="mirror://sourceforge/${PN}/${PN}_source_${MY_PV}.zip"

LICENSE="GPL-2"
KEYWORDS="amd64 ~ppc x86"
SLOT="0"
IUSE="doc jikes"

RDEPEND=">=virtual/jre-1.4
	=dev-java/jgoodies-looks-1.3*
	dev-java/backport-util-concurrent"

DEPEND=">=virtual/jdk-1.4
	dev-java/ant-core
	app-arch/unzip
	jikes? ( >=dev-java/jikes-1.17 )
	${RDEPEND}"

S="${WORKDIR}/${PN}_${MY_PV}"

src_unpack() {
	unpack ${A}
	cd ${S}

	epatch "${FILESDIR}/${P}-gentoo.patch"

	cat > "${T}/${PN}" <<-EOF
		#!/bin/bash

		cd "${GAMES_DATADIR}/${PN}"
		java -Dtriplea.root="${GAMES_DATADIR}/${PN}" \\
			-cp \$(java-config -p triplea,jgoodies-looks-1.3,backport-util-concurrent) \\
			games.strategy.engine.framework.GameRunner
	EOF

	# The default savedGames directory is in the install root.  This
	# sets it to use the users home directory.
	echo "triplea.saveGamesInHomeDir=true" > triplea.properties

	cd lib/
	rm *.jar
	java-pkg_jar-from jgoodies-looks-1.3
	java-pkg_jar-from backport-util-concurrent
}

src_compile() {
	local antflags="jar"

	use jikes && antflags="${antflags} -Dbuild.compiler=jikes"
	use doc && antflags="${antflags} javadoc"

	ant ${antflags} || die "compile problem"
}

src_install () {
	dodoc changelog.txt
	java-pkg_dohtml readme.html

	if use doc; then
		java-pkg_dohtml -r api
		java-pkg_dohtml -r doc/*
	fi
	java-pkg_dojar ${PN}.jar

	dogamesbin "${T}/${PN}" || die "dogamesbin failed"

	insinto "${GAMES_DATADIR}/${PN}"
	doins -r games/ || die "doins failed"
	prepgamesdirs
}
