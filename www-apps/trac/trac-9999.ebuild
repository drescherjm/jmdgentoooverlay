# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header$

EAPI="2"
ESVN_REPO_URI="http://svn.edgewall.com/repos/trac/trunk"
ESVN_PROJECT="trac"

inherit distutils webapp subversion

LANGS="ca_ES de_DE en_US et_EE fr_FR it_IT lv_LV nl_NL pt_PT sl_SI tr_TR zh_TW cs_CZ el_GR es_AR fa_IR gl_ES ja_JP pl_PL ro_RO sv_SE vi_VN cy_GB en_GB es_ES fi_FI hu_HU ko_KR nb_NO pt_BR ru_RU th_TH zh_CN"
NOSHORTLANGS="ca_ES gl_ES en_GB cy_GB zh_TW es_AR pt_BR"

DESCRIPTION="Trac is a minimalistic web-based project management, wiki and bug/issue tracking system."
HOMEPAGE="http://trac.edgewall.com/"
LICENSE="trac"

IUSE="cgi fastcgi mysql postgres sqlite subversion"

KEYWORDS="~x86 ~x86-fbsd ~amd64"

# doing so because tools, python packages... overlap
SLOT="0"
WEBAPP_MANUAL_SLOT="yes"

for X in ${LANGS} ; do
	if [ "${#X}" == 5 ] && ! has ${X} ${NOSHORTLANGS}; then
		IUSE="${IUSE} linguas_${X%%_*}"
	else
		IUSE="${IUSE} linguas_${X}"
	fi
done

DEPEND="
	${DEPEND}
	dev-python/setuptools
	"

RDEPEND="
	${RDEPEND}
	>=dev-python/genshi-0.6
	dev-python/pygments
	app-text/pytextile
	app-text/silvercity
	dev-python/Babel
	>=dev-python/docutils-0.3.9
	dev-python/pytz
	cgi? (
		virtual/httpd-cgi
	)
	fastcgi? (
		virtual/httpd-fastcgi
	)
	mysql? (
		>=dev-python/mysql-python-1.2.1
		>=virtual/mysql-4.1
	)
	postgres? (
		>=dev-python/psycopg-2
	)
	sqlite? (
		>=dev-db/sqlite-3.3.4
		|| (
			>=dev-lang/python-2.5[sqlite]
			>=dev-python/pysqlite-2.3.2
		)
	)
	subversion? (
		>=dev-util/subversion-1.4.2[python]
	)
	!www-apps/trac-webadmin
	"

S="${WORKDIR}"

linguas() {
	local LANG
	for LANG in ${LINGUAS}; do
		if has ${LANG} ${LANGS} ; then
			has ${LANG} ${linguas} || linguas="${linguas:+"${linguas} "}${LANG}"
			continue
		elif [[ " ${LANGS} " == *" ${LANG}_"* ]]; then
			for X in ${LANGS}; do
				if [[ "${X}" == "${LANG}_"* ]] && \
					[[ " ${NOSHORTLANGS} " != *" ${X} "* ]]; then
					has ${X} ${linguas} || linguas="${linguas:+"${linguas} "}${X}"
					continue 2
				fi
			done
		fi
		ewarn "Sorry, but ${PN} does not support the ${LANG} LINGUA"
	done
}

src_prepare() {
	sed -i "s|Genshi>=0.6dev-r960|Genshi>=0.6dev|g" setup.py || die "sed failed"

	linguas
	for X in ${linguas}; do
		"${python}" setup.py update_catalog -l ${X}
		"${python}" setup.py compile_catalog -f -l ${X}
	done
}

pkg_setup() {
	webapp_pkg_setup

	if ! use mysql && ! use postgres && ! use sqlite ; then
		eerror "You must select at least one database backend, by enabling"
		eerror "at least one of the 'mysql', 'postgres' or 'sqlite' USE flags."
		die "no database backend selected"
	fi

	enewgroup tracd
	enewuser tracd -1 -1 -1 tracd
}

src_install() {
	webapp_src_preinst
	distutils_src_install

	# project environments might go in here
	keepdir /var/lib/trac

	# Use this as the egg-cache for tracd
	dodir /var/lib/trac/egg-cache
	keepdir /var/lib/trac/egg-cache
	fowners tracd:tracd /var/lib/trac/egg-cache

	# documentation
	cp -r contrib "${D}"/usr/share/doc/${P}/

	# tracd init script
	newconfd "${FILESDIR}"/tracd.confd tracd
	newinitd "${FILESDIR}"/tracd.initd tracd

	if use cgi ; then
		cp cgi-bin/trac.cgi "${D}"/${MY_CGIBINDIR} || die
	fi
	if use fastcgi ; then
		cp cgi-bin/trac.fcgi "${D}"/${MY_CGIBINDIR} || die
	fi

	for lang in en; do
		webapp_postinst_txt ${lang} "${FILESDIR}"/postinst-${lang}.txt
		webapp_postupgrade_txt ${lang} "${FILESDIR}"/postupgrade-${lang}.txt
	done

	webapp_src_install
}
