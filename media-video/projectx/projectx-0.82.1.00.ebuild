# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/www/www.gentoo.org/raw_cvs/gentoo-x86/media-video/projectx/Attic/projectx-0.82.1.00.ebuild,v 1.5 2005/09/09 14:21:55 axxo dead $

inherit eutils java-pkg

MY_PN="ProjectX"
MY_P="${MY_PN}_Source_${PV}"

DESCRIPTION="Converts, splits and demuxes DVB and other MPEG recordings"
HOMEPAGE="http://sourceforge.net/projects/project-x/"
SRC_URI="mirror://sourceforge/project-x/${MY_P}.zip"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86 ~ppc ~amd64"
RDEPEND=">=virtual/jre-1.4
	dev-java/commons-net
	=dev-java/jakarta-oro-2.0*"
DEPEND=">=virtual/jdk-1.4
	${RDEPEND}
	app-arch/unzip
	jikes? ( dev-java/jikes )
	source? ( app-arch/zip )"

IUSE="doc jikes source"
S="${WORKDIR}/${MY_P}"

src_unpack() {
	unpack ${A}
	cd ${S}

	cp ${FILESDIR}/${PV}-build.xml ./build.xml

	cd lib
	rm -f *.jar
	java-pkg_jar-from jakarta-oro-2.0
	java-pkg_jar-from commons-net
}

src_compile() {
	local antflags="jar"
	use doc && antflags="${antflags} docs"
	use jikes && antflags="${antflags} -Dbuild.compiler=jikes"
	ant ${antflags} || die "compilation failed"
}

src_install() {
	java-pkg_dojar dist/${PN}.jar

	# generate a startup script
	echo "#!/bin/sh" > ${PN}
	echo "\$(java-config -J) -Xms32m -Xmx512m -cp \$(java-config -p	projectx,jakarta-oro-2.0,commons-net) net.sourceforge.dvb.projectx.common.X \"\$@\"" >> ${PN}

	dobin ${PN}

	if use doc; then
		java-pkg_dohtml -r apidocs/
		dodoc *.txt
	fi
	use source && java-pkg_dosrc src/*
}
