# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils flag-o-matic webapp depend.php

DESCRIPTION="ZABBIX is software for monitoring of your applications, network and servers."
HOMEPAGE="http://www.zabbix.com/"
SRC_URI="mirror://sourceforge/zabbix/${P}.tar.gz"
LICENSE="GPL-2"
SLOT="0"
WEBAPP_MANUAL_SLOT="yes"
KEYWORDS="~amd64 ~ppc x86"
IUSE="agent curl frontend jabber ldap mysql oracle postgres proxy server snmp sqlite3 openipmi"
DEPEND="virtual/libc
	snmp? ( net-analyzer/net-snmp )
	ldap? (
		net-nds/openldap
		=dev-libs/cyrus-sasl-2*
		net-libs/gnutls
	)
	mysql? ( virtual/mysql )
	sqlite3? ( =dev-db/sqlite-3* )
	postgres? ( virtual/postgresql-base )
	jabber? ( dev-libs/iksemel )
	curl? ( net-misc/curl )
  openipmi? ( sys-libs/openipmi )"
RDEPEND="${RDEPEND}
	proxy? ( net-analyzer/fping )
	server? ( net-analyzer/fping )"

useq frontend && need_php_httpd

pkg_setup() {
	if useq server || useq proxy ; then
		local dbnum dbtypes="mysql oracle postgres sqlite3" dbtype
		declare -i dbnum=0
		for dbtype in ${dbtypes}; do
			useq ${dbtype} && let dbnum++
		done
		if [ ${dbnum} -gt 1 ]; then
			eerror
			eerror "You can't use more than one database type in Zabbix."
			eerror "Select exactly one database type out of these: ${dbtypes}"
			eerror
			die "Multiple database types selected."
		elif [ ${dbnum} -lt 1 ]; then
			eerror
			eerror "Select exactly one database type out of these: ${dbtypes}"
			eerror
			die "No database type selected."
		fi
		if useq oracle; then
			if [ -z "${ORACLE_HOME}" ]; then
				eerror
				eerror "The environment variable ORACLE_HOME must be set"
				eerror "and point to the correct location."
				eerror "It looks like you don't have Oracle installed."
				eerror
				die "Environment variable ORACLE_HOME is not set"
			fi
			if has_version 'dev-db/oracle-instantclient-basic'; then
				ewarn
				ewarn "Please ensure you have a full install of the Oracle client."
				ewarn "dev-db/oracle-instantclient* is NOT sufficient."
				ewarn
			fi
		fi
	fi

	if useq frontend; then
		webapp_pkg_setup
		require_gd
	fi

	enewgroup zabbix
	enewuser zabbix -1 -1 /var/lib/zabbix/home zabbix
}

pkg_postinst() {
	if useq server || useq proxy ; then
		elog
		elog "You need to configure your database for Zabbix."
		elog
		elog "Have a look at /usr/share/zabbix/database for"
		elog "database creation and upgrades."
		elog
		elog "For more info read the Zabbix manual at"
		elog "http://www.zabbix.com/documentation.php"
		elog

		zabbix_homedir="$(egetent passwd zabbix | cut -d : -f 6 )"
		if [ -n "${zabbix_homedir}" ] && \
		   [ "${zabbix_homedir}" != "/var/lib/zabbix/home" ]; then
			ewarn
			ewarn "The user 'zabbix' should have his homedir changed"
			ewarn "to /var/lib/zabbix/home if you want to use"
			ewarn "custom alert scripts."
			ewarn
			ewarn "A real homedir might be needed for configfiles"
			ewarn "for custom alert scripts (e.g. ~/.sendxmpprc when"
			ewarn "using sendxmpp for Jabber alerts)."
			ewarn
			ewarn "To change the homedir use:"
			ewarn "  usermod -d /var/lib/zabbix/home zabbix"
			ewarn
		fi
	fi

	if useq server; then
		elog
		elog "For distributed monitoring you have to run:"
		elog
		elog "zabbix_server -n <nodeid>"
		elog
		elog "This will convert database data for use with Node ID"
		elog "and also adds a local node."
		elog
	fi

	elog "--"
	elog
	elog "Add these lines in the /etc/services :"
	elog
	elog "zabbix-agent     10050/tcp Zabbix Agent"
	elog "zabbix-agent     10050/udp Zabbix Agent"
	elog "zabbix-trapper   10051/tcp Zabbix Trapper"
	elog "zabbix-trapper   10051/udp Zabbix Trapper"
	elog

	# repeat fowners/fperms functionality from src_install()
	# here to catch wrong permissions on existing files in
	# the live filesystem (yeah, that sucks).
	chown -R zabbix:zabbix \
		"${ROOT}"/etc/zabbix \
		"${ROOT}"/var/lib/zabbix \
		"${ROOT}"/var/lib/zabbix/home \
		"${ROOT}"/var/lib/zabbix/scripts \
		"${ROOT}"/var/log/zabbix \
		"${ROOT}"/var/run/zabbix
	chmod 0750 \
		"${ROOT}"/etc/zabbix \
		"${ROOT}"/var/lib/zabbix \
		"${ROOT}"/var/lib/zabbix/home \
		"${ROOT}"/var/lib/zabbix/scripts \
		"${ROOT}"/var/log/zabbix \
		"${ROOT}"/var/run/zabbix

	chmod 0640 \
		"${ROOT}"/etc/zabbix/zabbix_*

	if useq server || useq proxy ; then
		# check for fping
		fping_perms=$(stat -c %a /usr/sbin/fping 2>/dev/null)
		case "${fping_perms}" in
			4[157][157][157])
				;;
			*)
				ewarn
				ewarn "If you want to use the checks 'icmpping' and 'icmppingsec',"
				ewarn "you have to make /usr/sbin/fping setuid root and executable"
				ewarn "by everyone. Run the following command to fix it:"
				ewarn
				ewarn "  chmod u=rwsx,g=rx,o=rx /usr/sbin/fping"
				ewarn
				ewarn "Please be aware that this might impose a security risk,"
				ewarn "depending on the code quality of fping."
				ewarn
				ebeep 3
				epause 5
				;;
		esac
	fi
}

#src_unpack() {
#	unpack ${A}
#	epatch "${FILESDIR}"/${PV}/some.patch
#}

src_compile() {
	econf \
		$(use_enable server) \
		$(use_enable proxy) \
		$(use_enable agent) \
		$(use_with ldap) \
		$(use_with snmp net-snmp) \
		$(use_with mysql) \
		$(use_with postgres pgsql) \
		$(use_with oracle) \
		$(use_with sqlite3) \
		$(use_with jabber) \
		$(use_with curl libcurl) \
	$(use_with openipmi openipmi) \
		|| die "econf failed"
	emake || die "emake failed"
}

src_install() {
	dodir \
		/etc/zabbix \
		/var/lib/zabbix \
		/var/lib/zabbix/home \
		/var/lib/zabbix/scripts \
		/var/log/zabbix \
		/var/run/zabbix

	keepdir \
		/etc/zabbix \
		/var/lib/zabbix \
		/var/lib/zabbix/home \
		/var/lib/zabbix/scripts \
		/var/log/zabbix \
		/var/run/zabbix

	if useq server; then
		insinto /etc/zabbix
		doins \
			"${FILESDIR}/${PV}"/zabbix_server.conf \
			"${FILESDIR}/${PV}"/zabbix_trapper.conf 
		doinitd \
			"${FILESDIR}/${PV}"/init.d/zabbix-server
		dosbin \
			src/zabbix_server/zabbix_server
		dodir \
			/usr/share/zabbix/database
		insinto /usr/share/zabbix/database
		doins -r \
			upgrades \
			create
		fowners zabbix:zabbix \
			/etc/zabbix/zabbix_server.conf \
			/etc/zabbix/zabbix_trapper.conf
		fperms 0640 \
			/etc/zabbix/zabbix_server.conf \
			/etc/zabbix/zabbix_trapper.conf
	fi

	if useq agent; then
		insinto /etc/zabbix
		doins \
			"${FILESDIR}/${PV}"/zabbix_agent.conf \
			"${FILESDIR}/${PV}"/zabbix_agentd.conf
		doinitd \
			"${FILESDIR}/${PV}"/init.d/zabbix-agentd
		dosbin \
			src/zabbix_agent/zabbix_agent \
			src/zabbix_agent/zabbix_agentd
		dobin \
			src/zabbix_sender/zabbix_sender \
			src/zabbix_get/zabbix_get
		fowners zabbix:zabbix \
			/etc/zabbix/zabbix_agent.conf \
			/etc/zabbix/zabbix_agentd.conf
		fperms 0640 \
			/etc/zabbix/zabbix_agent.conf \
			/etc/zabbix/zabbix_agentd.conf
	fi

	fowners zabbix:zabbix \
		/etc/zabbix \
		/var/lib/zabbix \
		/var/lib/zabbix/home \
		/var/lib/zabbix/scripts \
		/var/log/zabbix \
		/var/run/zabbix
	fperms 0750 \
		/etc/zabbix \
		/var/lib/zabbix \
		/var/lib/zabbix/home \
		/var/lib/zabbix/scripts \
		/var/log/zabbix \
		/var/run/zabbix

	dodoc README INSTALL NEWS ChangeLog

	if useq frontend; then
		webapp_src_preinst
		cp -R frontends/php/* "${D}/${MY_HTDOCSDIR}"
		webapp_postinst_txt en "${FILESDIR}/${PV}"/postinstall-en.txt
		webapp_configfile \
			"${MY_HTDOCSDIR}"/include/db.inc.php \
			"${MY_HTDOCSDIR}"/include/config.inc.php
		webapp_src_install
	fi
}
