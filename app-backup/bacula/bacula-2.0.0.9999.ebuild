# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-backup/bacula/bacula-1.38.9.ebuild,v 1.2 2006/09/21 22:22:11 blubb Exp $

inherit eutils cvs

IUSE="bacula-clientonly bacula-console bacula-nodir bacula-nosd
bacula-split-init doc gnome logrotate logwatch mysql postgres python readline
sqlite sqlite3 ssl static tcpd wxwindows bacula-bat X"
KEYWORDS="~amd64 ~sparc ~x86 amd64 x86"

DESCRIPTION="Featureful client/server network backup suite"
HOMEPAGE="http://www.bacula.org/"

DOC_VER="2.0.0"
SRC_URI="doc? ( mirror://sourceforge/bacula/${PN}-docs-${DOC_VER}.tar.gz )"

ECVS_SERVER="bacula.cvs.sourceforge.net:/cvsroot/bacula"
ECVS_USER="anonymous"
ECVS_PASS=""
ECVS_AUTH="pserver"
ECVS_MODULE="bacula"


LICENSE="GPL-2"
SLOT="0"

S="${WORKDIR}/bacula"

DEPEND="
	>=sys-libs/zlib-1.1.4
	dev-libs/gmp
	!bacula-clientonly? (
		postgres? ( >=dev-db/postgresql-7.4.0 )
		mysql? ( >=dev-db/mysql-3.23 )
		sqlite? ( =dev-db/sqlite-2* )
		sqlite3? ( >=dev-db/sqlite-3.0.0 )
		virtual/mta
	)
	bacula-console? (
		wxwindows? ( >=x11-libs/wxGTK-2.4.2 )
		gnome? (
			>=gnome-base/libgnome-2
			app-admin/gnomesu
		)
	)
	bacula-bat? (
		>=x11-libs/qt-4.2.0
	)
	ssl? ( dev-libs/openssl )
	logrotate? ( app-admin/logrotate )
	logwatch? ( sys-apps/logwatch )
	tcpd? ( >=sys-apps/tcp-wrappers-7.6 )
	readline? ( >=sys-libs/readline-4.1 )"
RDEPEND="${DEPEND}
	!bacula-clientonly? (
		sys-block/mtx
		app-arch/mt-st
	)"

pkg_setup() {
	export mydb=""
	dbcnt=0
	if ! use bacula-clientonly ; then
		if use mysql ; then
			mydb="mysql"
			dbcnt="$((${dbcnt} + 1))"
		fi
		if use postgres ; then
			mydb="postgresql"
			dbcnt="$((${dbcnt} + 1))"
		fi
		if use sqlite ; then
			mydb="sqlite"
			dbcnt="$((${dbcnt} + 1))"
		fi
		if use sqlite3 ; then
			mydb="sqlite3"
			dbcnt="$((${dbcnt} + 1))"
		fi
		export mydb="${mydb}"

		if [[ "${dbcnt}" -eq 0 ]] ; then
			eerror "To use ${P} it is required to set a database in the USE flags."
			eerror "Supported databases are mysql, postgresql, sqlite, sqlite3"
			die "You must set a supported database type."
		fi
	fi
	if ! use bacula-clientonly ; then
		if [[ "${dbcnt}" -gt 1 ]] ; then
			eerror "You have set ${P} to use multiple database types."
			eerror "I don't know which to set as the default!"
			eerror "You can use /etc/portage/package.use to set per-package USE flags"
			eerror "Set it so only one database type, mysql, postgres, sqlite, sqlite3"
			die "Please set only one database type"
		fi
	fi

	# create the daemon group and user
	HAVE_BACULA_GROUP="`grep bacula\: /etc/group 2>/dev/null`"
	if [ -z "${HAVE_BACULA_GROUP}" ]; then
		enewgroup bacula
		einfo "The group bacula has been created. Any users you add to this"
		einfo "group have access to files created by the daemons."
		einfo ""
	fi
	if ! use bacula-clientonly ; then
		HAVE_BACULA_USER="`id -u bacula 2>/dev/null`"
		if [ -z "${HAVE_BACULA_USER}" ] ; then
			enewuser "bacula" -1 -1 "/var/lib/bacula" "bacula,disk,tape,cdrom,cdrw"
			einfo "The user bacula has been created.  Please see the bacula manual"
			einfo "for information about running bacula as a non-root user."
			einfo ""
		fi
	fi
}

src_unpack() {

#	ECVS_TOP_DIR="${DISTDIR}/cvs-src/${ECVS_MODULE}"

	cvs_src_unpack

	cd ${S}
	# adjusts default configuration files for several binaries
	# to /etc/bacula/<config> instead of ./<config>
	#epatch ${FILESDIR}/${P}-default-configs.patch
}

src_compile() {
	local myconf=""
	if use bacula-clientonly ; then
		myconf="${myconf} \
			`use_enable bacula-clientonly client-only` \
			`use_enable static static-fd`"
	fi
	if use bacula-console ; then
		myconf="${myconf} \
			`use_with X x` \
			`use_enable gnome` \
			`use_enable gnome tray-monitor` \
			`use_enable wxwindows wx-console` \
			`use_enable static static-cons`"
	fi
	myconf="${myconf} \
		`use_with python` \
		`use_with readline` \
		`use_with ssl openssl` \
		`use_with tcpd tcp-wrappers`"

	if ! use bacula-clientonly; then
		# select database support
		if [ ${mydb} == "postgresql" ]; then
			myconf="${myconf} `use_with postgres postgresql`"
		else
			myconf="${myconf} `use_with ${mydb}`"
		fi
		myconf="${myconf} \
			`use_enable static static-tools` \
			`use_enable static static-fd` \
			`use_enable !bacula-nodir build-dird` \
			`use_enable !bacula-nosd build-stored`"
		if ! use bacula-nodir ; then
			myconf="${myconf} `use_enable static static-dir`"
		fi
		if ! use bacula-nosd ; then
			myconf="${myconf} `use_enable static static-sd`"
		fi

	fi

	./configure \
		--prefix=/usr \
		--mandir=/usr/share/man \
		--with-pid-dir=/var/run \
		--sysconfdir=/etc/bacula \
		--infodir=/usr/share/info \
		--with-subsys-dir=/var/lock/subsys \
		--with-working-dir=/var/lib/bacula \
		--with-scriptdir=/usr/libexec/bacula \
		--with-dir-user=bacula \
		--with-dir-group=bacula \
		--with-sd-user=root \
		--with-sd-group=bacula \
		--with-fd-user=root \
		--with-fd-group=bacula \
		--enable-smartalloc \
		--host=${CHOST} ${myconf} || die "Configure failed!"

	emake || die "Failed primary build!"

	if use bacula-bat; then
		cd src/qt-console
		rm Makefile
		qmake
		emake || die "Failed to build the qt-4 console"
	fi

}

src_install() {
	emake DESTDIR=${D} install || die "Failed install to ${D} !"

	if use static ; then
		cd ${D}/usr/sbin
		mv static-bacula-fd bacula-fd
		mv static-bconsole bconsole
		if ! use bacula-clientonly ; then
			mv static-bacula-dir bacula-dir
			mv static-bacula-sd bacula-sd
		fi
		if use gnome ; then
			mv static-gnome-console gnome-console
		fi
		cd ${S}
	fi

	if use bacula-console ; then
		if use gnome ; then
			emake DESTDIR=${D} \
				install-menu \
				install-menu-xsu || die "Failed to install gnome menu files to ${D}" \
			make_desktop_entry \
				"gnome-console -c /etc/bacula/gnome-console.conf" \
				"Bacula Console" /usr/share/pixmaps/bacula.png "app-admin" \
				"/usr/sbin"
		fi
	fi

	if use bacula-bat; then
		cp ${S}/src/qt-console/bat ${D}/usr/sbin
	fi

	# extra files which 'make install' doesn't cover
	if ! use bacula-clientonly ; then
	    # the database update scripts
		diropts -m0750
		dodir /usr/libexec/bacula/updatedb
		insinto /usr/libexec/bacula/updatedb/
		insopts -m0754
		doins ${S}/updatedb/*
		fperms 0640 /usr/libexec/bacula/updatedb/README

		# the logrotate configuration
		if use logrotate ; then
			diropts -m0755
			dodir /etc/logrotate.d
			insinto /etc/logrotate.d
			insopts -m0644
			newins ${S}/scripts/logrotate bacula
		fi

		# the logwatch scripts
		if use logwatch ; then
			diropts -m0750
			dodir /etc/log.d/scripts/services
			dodir /etc/log.d/conf/logfiles
			dodir /etc/log.d/conf/services
			cd ${S}/scripts/logwatch
			emake DESTDIR=${D} install || die "Failed to install logwatch scripts to ${D} !"
			cd ${S}
		fi
	fi

	# documentation
	for my_doc in ${S}/{ChangeLog,LICENSE,README,ReleaseNotes,kernstodo,doc/BaculaRoadMap_*.pdf}
	do
		dodoc ${my_doc}
	done
	if use doc ; then
		dodoc ${WORKDIR}/${PN}-docs-${DOC_VER}/developers/developers.pdf
		dodoc ${WORKDIR}/${PN}-docs-${DOC_VER}/manual/bacula.pdf
		diropts -m0755
		dodir /usr/share/doc/${PF}/developers
		dodir /usr/share/doc/${PF}/manual
		insopts -m0644
		insinto /usr/share/doc/${PF}/developers
		doins ${WORKDIR}/${PN}-docs-${DOC_VER}/developers/developers/*
		insinto /usr/share/doc/${PF}/manual
		doins ${WORKDIR}/${PN}-docs-${DOC_VER}/manual/bacula/*
	fi

	# clean up permissions left broken by install
	fperms 0644 ${D}/usr/libexec/bacula/query.sql
	prepall

	# setup init scripts
	my_services="fd"
	if ! use bacula-clientonly ; then
		if ! use bacula-no-dir ; then
			my_services="${my_services} dir"
		fi
		if ! use bacula-no-sd ; then
			my_services="${my_services} sd"
		fi
	fi
	exeinto /etc/init.d/
	insinto /etc/conf.d/
	if use bacula-split-init ; then
		my_scripts=""
		for service in ${my_services} ; do
			my_scripts="${my_scripts} bacula-${service}"
		done
	else
		my_scripts="bacula-all"
	fi
	for script in ${my_scripts}; do
		cp ${FILESDIR}/${PV}/${script}-conf ${T}/${script}.conf
		cp ${FILESDIR}/${PV}/${script}-init ${T}/${script}.init
		if [ "${mydb}" == "sqlite" ]; then
			sed -i -e "s:%database%::" ${T}/${script}.init
		else
			sed -i -e "s:%database%:${mydb}:" ${T}/${script}.init
		fi
		sed -i -e "s:%services%:${my_services}:" ${T}/${script}.conf
		newexe ${T}/${script}.init ${script}
		newins ${T}/${script}.conf ${script}
	done

	# make sure the working directory exists
	diropts -m0750
	keepdir /var/lib/bacula
}

pkg_postinst() {
	if use bacula-clientonly ; then
		fowners root:bacula /var/lib/bacula
	else
		fowners bacula:bacula /var/lib/bacula
	fi

	if ! use bacula-clientonly && ! use bacula-no-dir ; then
		einfo "If this is a new install, you must create the ${mydb} databases with:"
		einfo " /usr/libexec/bacula/create_${mydb}_database"
		einfo " /usr/libexec/bacula/make_${mydb}_tables"
		einfo " /usr/libexec/bacula/grant_${mydb}_privileges"
		einfo ""
		einfo "If you're upgrading from a major release, you must upgrade your bacula catalog database."
		einfo "Please read the manual chapter for how to upgrade your database."
		einfo "You can find database upgrade scripts in /usr/libexec/bacula/updatedb."
		einfo ""
	fi
}
