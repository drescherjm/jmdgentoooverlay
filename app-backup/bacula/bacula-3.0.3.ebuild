# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-backup/bacula/bacula-3.0.2.ebuild,v 1.3 2009/09/30 16:20:33 ayoy Exp $

EAPI="2"
inherit eutils

IUSE="bacula-clientonly bacula-console bacula-nodir bacula-nosd gnome ipv6 logwatch mysql postgres python qt4 readline sqlite +sqlite3 ssl static tcpd wxwindows X"
# bacula-web bimagemgr brestore bweb
KEYWORDS="~amd64 ~hppa ~ppc ~sparc ~x86"

DESCRIPTION="Featureful client/server network backup suite"
HOMEPAGE="http://www.bacula.org/"

MY_PV=${PV/_beta/-b}
MY_P=${PN}-${MY_PV}
S=${WORKDIR}/${MY_P}
#DOC_VER="${MY_PV}"
#DOC_SRC_URI="mirror://sourceforge/bacula/${PN}-docs-${DOC_VER}.tar.bz2"
#GUI_VER="${PV}"
#GUI_SRC_URI="mirror://sourceforge/bacula/${PN}-gui-${GUI_VER}.tar.gz"
SRC_URI="mirror://sourceforge/bacula/${MY_P}.tar.gz"
#		doc? ( ${DOC_SRC_URI} )
#		bacula-web? ( ${GUI_SRC_URI} )
#		bimagemgr? ( ${GUI_SRC_URI} )
#		brestore? ( ${GUI_SRC_URI} )
#		bweb? ( ${GUI_SRC_URI} )

LICENSE="GPL-2"
SLOT="0"

DEPEND="
	>=sys-libs/zlib-1.1.4
	dev-libs/gmp
	!bacula-clientonly? (
		postgres? ( >=virtual/postgresql-server-7.4 )
		mysql? ( virtual/mysql )
		sqlite? ( =dev-db/sqlite-2* )
		sqlite3? ( >=dev-db/sqlite-3.0.0 )
		virtual/mta
	)
	bacula-console? (
		wxwindows? ( =x11-libs/wxGTK-2.6* )
		qt4? (
			x11-libs/qt-svg:4
			>=x11-libs/qwt-5
		)
		gnome? (
			>=gnome-base/libgnome-2
			>=gnome-base/libgnomeui-2
			x11-libs/gksu
		)
	)
	ssl? ( dev-libs/openssl )
	logwatch? ( sys-apps/logwatch )
	tcpd? ( >=sys-apps/tcp-wrappers-7.6 )
	readline? ( >=sys-libs/readline-4.1 )
	python? ( dev-lang/python[threads] )"
#	doc? (
#		virtual/ghostscript
#		dev-tex/latex2html[png]
#		app-text/dvipdfm
#	)
RDEPEND="${DEPEND}
	!bacula-clientonly? (
		sys-block/mtx
		app-arch/mt-st
	)"

pkg_setup() {
	local dbnum
	declare -i dbnum=0
	if ! useq bacula-clientonly; then
		if useq mysql; then
			export mydbtype='mysql'
			let dbnum++
		fi
		if useq postgres; then
			export mydbtype='postgresql'
			let dbnum++
		fi
		if useq sqlite; then
			export mydbtype='sqlite'
			let dbnum++
		fi
		if useq sqlite3; then
			export mydbtype='sqlite3'
			let dbnum++
		fi
		if [[ "${dbnum}" -lt 1 ]]; then
			eerror
			eerror "To use ${P} it is required to set a database in the USE flags."
			eerror "Supported databases are mysql, postgresql, sqlite, sqlite3"
			eerror
			die "No database type selected."
		elif [[ "${dbnum}" -gt 1 ]]; then
			eerror
			eerror "You have set ${P} to use multiple database types."
			eerror "I don't know which to set as the default!"
			eerror "You can use /etc/portage/package.use to set per-package USE flags"
			eerror "Set it so only one database type, mysql, postgres, sqlite, sqlite3"
			eerror
			die "Multiple database types selected."
		fi
	fi

	# create the daemon group and user
	if [ -z "$(egetent group bacula)" ]; then
		enewgroup bacula
		einfo
		einfo "The group 'bacula' has been created. Any users you add to this"
		einfo "group have access to files created by the daemons."
		einfo
	fi
	if ! useq bacula-clientonly; then
		if [ -z "$(egetent passwd bacula)" ]; then
			enewuser bacula -1 -1 /var/lib/bacula bacula,disk,tape,cdrom,cdrw
			einfo
			einfo "The user 'bacula' has been created.  Please see the bacula manual"
			einfo "for information about running bacula as a non-root user."
			einfo
		fi
	fi
}

src_prepare() {
	# adjusts default configuration files for several binaries
	# to /etc/bacula/<config> instead of ./<config>
	pushd src && epatch "${FILESDIR}/${PV}/${PN}"-default-configs.patch && popd

	# replaces (deprecated) gnomesu with gksu in the gnome menu files
	useq bacula-console && useq gnome && epatch "${FILESDIR}/${PV}/${PN}"-gnomesu2gksu.diff

	# apply upstream patches
	#epatch "${FILESDIR}"/${PV}/${PV}-foo.patch
}

src_configure() {
	local myconf=''

	if useq bacula-clientonly; then
		myconf="${myconf} \
			$(use_enable bacula-clientonly client-only) \
			$(use_enable static static-fd)"
	else
		myconf="${myconf} \
			--with-${mydbtype} \
			$(use_enable static static-tools) \
			$(use_enable static static-fd) \
			$(use_enable !bacula-nodir build-dird) \
			$(use_enable !bacula-nosd build-stored)"
		if ! useq bacula-nodir; then
			myconf="${myconf} $(use_enable static static-dir)"
		fi
		if ! useq bacula-nosd; then
			myconf="${myconf} $(use_enable static static-sd)"
		fi
		case "${mydbtype}" in
			sqlite) ;;
			*) myconf="${myconf} --enable-batch-insert" ;;
		esac
	fi

	if useq bacula-console; then
		if useq qt4 && has_version '<x11-libs/qwt-5'; then
			eerror "x11-libs/qwt found in a version < 5, thus the"
			eerror "compilation of 'bat' would fail (see"
			eerror "http://bugs.gentoo.org/188477#c11 for details)."
			eerror "please either unmerge <x11-libs/qwt-5 or disable"
			eerror "the qt4 USE flag to disable building 'bat'."
			die "incompatible slotted qwt version found"
		fi
		myconf="${myconf} \
			$(use_with X x) \
			$(use_enable gnome) \
			$(use_enable gnome tray-monitor) \
			$(use_enable wxwindows bwx-console) \
			$(use_enable qt4 bat) \
			$(use_enable static static-cons)"
	fi

	myconf="${myconf} \
		$(use_with python) \
		$(use_enable readline) \
		$(use_with readline readline /usr) \
		$(use_with ssl openssl) \
		$(use_enable ipv6) \
		$(use_with tcpd tcp-wrappers)"

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
		--host=${CHOST} \
		${myconf} \
		|| die "configure failed"
}

src_compile() {
	emake || die "emake failed"

	# build various GUIs from bacula-gui tarball
#	if useq bacula-web || useq bimagemgr || useq brestore || useq bweb; then
#		pushd "${WORKDIR}/${PN}-gui-${GUI_VER}"
#		local myconf_gui=''
#		if useq bimagemgr; then
#			## TODO FIXME: webapp-config? !apache?
#			myconf_gui="${myconf_gui} \
#				--with-bimagemgr-cgidir=/var/www/localhost/cgi-bin \
#				--with-bimagemgr-docdir=/var/www/localhost/htdocs \
#				--with-bimagemgr-binowner=root \
#				--with-bimagemgr-bingroup=root \
#				--with-bimagemgr-dataowner=apache \
#				--with-bimagemgr-datagroup=apache \
#				"
#		fi
#		./configure \
#			--with-bacula="${S}" \
#			${myconf} \
#			|| die "configure for bacula-gui failed"
#		## TODO FIXME: install files (see bacula-gui.spec)
#		if useq bacula-web; then
#			: install
#		fi
#		if useq bimagemgr; then
#			: install
#		fi
#		if useq brestore; then
#			: install
#		fi
#		if useq bweb; then
#			: install
#		fi
#		popd
#	fi

	# build docs from bacula-docs tarball
#	if useq doc; then
#		pushd "${WORKDIR}/${PN}-docs-${DOC_VER}"
#		./configure \
#			--with-bacula="${S}" \
#			|| die "configure for bacula-docs failed"
#		emake -j1 || die "emake for bacula-docs failed"
#		popd
#	fi
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"

	# install bat when enabled (for some reason ./configure doesn't pick this up)
	if useq bacula-console && useq qt4; then
		dosbin "${S}"/src/qt-console/.libs/bat
	fi

	# remove some scripts we don't need at all
	rm -f "${D}"/usr/libexec/bacula/{bacula,bacula-ctl-dir,bacula-ctl-fd,bacula-ctl-sd,startmysql,stopmysql}

	# rename statically linked apps
	if useq static; then
		pushd "${D}"/usr/sbin
		mv static-bacula-fd bacula-fd
		mv static-bconsole bconsole
		if ! useq bacula-clientonly; then
			mv static-bacula-dir bacula-dir
			mv static-bacula-sd bacula-sd
		fi
		if useq bacula-console && useq gnome; then
			mv static-gnome-console gnome-console
		fi
		if useq bacula-console && useq qt4; then
			mv static-bat bat
		fi
		popd
	fi

	# gnome-console menu entries using gksu
	if useq bacula-console && useq gnome; then
		emake DESTDIR="${D}" install-menu-xsu \
			|| die "Failed to install gnome menu files"
	fi

	# extra files which 'make install' doesn't cover
	if ! useq bacula-clientonly; then
	    # the database update scripts
		diropts -m0750
		insinto /usr/libexec/bacula/updatedb
		insopts -m0754
		doins "${S}"/updatedb/*
		fperms 0640 /usr/libexec/bacula/updatedb/README

		# the logrotate configuration
		# (now unconditional wrt bug #258187)
		diropts -m0755
		insinto /etc/logrotate.d
		insopts -m0644
		newins "${S}"/scripts/logrotate bacula

		# the logwatch scripts
		if useq logwatch; then
			diropts -m0750
			dodir /etc/log.d/scripts/services
			dodir /etc/log.d/scripts/shared
			dodir /etc/log.d/conf/logfiles
			dodir /etc/log.d/conf/services
			cd "${S}"/scripts/logwatch
			emake DESTDIR="${D}" install || die "Failed to install logwatch scripts"
			cd "${S}"
		fi
	fi

	# remove unwanted files
	if ! use bacula-console; then
		rm -vf "${D}"/etc/bacula/bconsole.conf
		rm -vf "${D}"/usr/sbin/bconsole
		rm -vf "${D}"/usr/libexec/bacula/bconsole
	fi
	if ! ( use bacula-console && use gnome ); then
		rm -vf "${D}"/usr/share/man/man1/bacula-bgnome-console.1*
		rm -vf "${D}"/usr/libexec/bacula/gconsole
	fi
	if ! ( use bacula-console && use wxwindows ); then
		rm -vf "${D}"/usr/share/man/man1/bacula-bwxconsole.1*
	fi
	if use bacula-clientonly; then
		rm -vf "${D}"/usr/share/man/man1/bat.1*
		rm -vf "${D}"/usr/share/man/man1/bacula-tray-monitor.1*
	fi
	if use bacula-clientonly || use bacula-nodir; then
		rm -vf "${D}"/usr/share/man/man8/bacula-dir.8*
		rm -vf "${D}"/usr/share/man/man8/dbcheck.8*
		rm -vf "${D}"/usr/share/man/man1/bsmtp.1*
		rm -vf "${D}"/usr/libexec/bacula/create_*_database
		rm -vf "${D}"/usr/libexec/bacula/drop_*_database
		rm -vf "${D}"/usr/libexec/bacula/make_*_tables
		rm -vf "${D}"/usr/libexec/bacula/update_*_tables
		rm -vf "${D}"/usr/libexec/bacula/drop_*_tables
		rm -vf "${D}"/usr/libexec/bacula/grant_*_privileges
		rm -vf "${D}"/usr/libexec/bacula/*_catalog_backup
	fi
	if use bacula-clientonly || use bacula-nosd; then
		rm -vf "${D}"/usr/share/man/man8/bacula-sd.8*
		rm -vf "${D}"/usr/share/man/man8/bcopy.8*
		rm -vf "${D}"/usr/share/man/man8/bextract.8*
		rm -vf "${D}"/usr/share/man/man8/bls.8*
		rm -vf "${D}"/usr/share/man/man8/bscan.8*
		rm -vf "${D}"/usr/share/man/man8/btape.8*
		rm -vf "${D}"/usr/libexec/bacula/disk-changer
		rm -vf "${D}"/usr/libexec/bacula/mtx-changer
		rm -vf "${D}"/usr/libexec/bacula/dvd-handler
	fi

	# documentation
	for d in "${S}"/{ChangeLog,LICENSE,README,ReleaseNotes,SUPPORT,kernstodo,projects}; do
		dodoc "${d}"
	done
#	if useq doc; then
#		for i in catalog concepts console developers install problems utility; do
#			dodoc "${WORKDIR}/${PN}-docs-${DOC_VER}"/manuals/en/${i}/${i}.pdf
#		done
#	fi

	# setup init scripts
	myscripts="bacula-fd"
	if ! useq bacula-clientonly; then
		if ! useq bacula-nodir; then
			myscripts="${myscripts} bacula-dir"
		fi
		if ! useq bacula-nosd; then
			myscripts="${myscripts} bacula-sd"
		fi
	fi
	for script in ${myscripts}; do
		# copy over init script and config to a temporary location
		# so we can modify them as needed
		cp "${FILESDIR}/${PV}/${script}"-conf "${T}/${script}".conf || die "failed to copy ${script}-conf"
		cp "${FILESDIR}/${PV}/${script}"-init "${T}/${script}".init || die "failed to copy ${script}-init"
		# set database dependancy for the director init scripts
		case "${script}" in
			bacula-dir)
				case "${mydbtype}" in
					sqlite*)
						# sqlite + sqlite3 databases don't have daemons
						sed -i -e 's/need "%database%"/:/g' "${T}/${script}".init
						;;
					*)
						# all other databases have daemons
						sed -i -e "s:%database%:${mydbtype}:" "${T}/${script}".init
						;;
				esac
				;;
			*)
				;;
		esac
		# install init script and config
		newinitd "${T}/${script}".init "${script}"
		newconfd "${T}/${script}".conf "${script}"
	done

	# make sure the working directory exists
	diropts -m0750
	keepdir /var/lib/bacula

	# make sure bacula group can execute bacula libexec scripts
	fowners -R root:bacula /usr/libexec/bacula
}

pkg_postinst() {
	if useq bacula-clientonly; then
		fowners root:bacula /var/lib/bacula
	else
		fowners bacula:bacula /var/lib/bacula
	fi

	if ! useq bacula-clientonly && ! useq bacula-nodir; then
		einfo
		einfo "If this is a new install, you must create the ${mydbtype} databases with:"
		einfo "  /usr/libexec/bacula/create_${mydbtype}_database"
		einfo "  /usr/libexec/bacula/make_${mydbtype}_tables"
		einfo "  /usr/libexec/bacula/grant_${mydbtype}_privileges"
		einfo
		einfo "If you're upgrading from a major release, you must upgrade your bacula catalog database."
		einfo "Please read the manual chapter for how to upgrade your database."
		einfo "You can find database upgrade scripts in /usr/libexec/bacula/updatedb."
		einfo
	fi

	ewarn
	ewarn "*** ATTENTION! IMPORTANT! ATTENTION! IMPORTANT! ATTENTION! IMPORTANT! ***"
	ewarn
	ewarn "The bundled catalog backup script (/usr/libexec/bacula/make_catalog_backup)"
	ewarn "is INSECURE. The script needs to be called with the database access password"
	ewarn "as a command line parameter, thus, the password can be seen from any other"
	ewarn "user on the system (if not using some non-default hardened/patched kernel"
	ewarn "with /proc restrictions)!"
	ewarn
	ewarn "Our advice is to NOT USE the bundled script at all, but instead use something"
	ewarn "like this in your catalog backup job definition (example using MySQL as the"
	ewarn "catalog database):"
	ewarn
	ewarn "RunBeforeJob = \"mysqldump --defaults-file=/etc/bacula/my.cnf --opt -f -r /var/lib/bacula/bacula.sql bacula\""
	ewarn "RunAfterJob  = \"rm -f /var/lib/bacula/bacula.sql\""
	ewarn
	ewarn "This requires you to put all database access parameters (like user, host and"
	ewarn "password) into a dedicated file (/etc/bacula/my.cnf in this example) which"
	ewarn "can (and should!) be secured by simple filesystem access permissions."
	ewarn
	ewarn "See also:"
	ewarn "http://www.bacula.org/en/rel-manual/Bacula_Security_Issues.html"
	ewarn "http://www.bacula.org/en/rel-manual/Catalog_Maintenance.html#BackingUpBaculaSecurityConsiderations"
	ewarn
	ewarn "*** ATTENTION! IMPORTANT! ATTENTION! IMPORTANT! ATTENTION! IMPORTANT! ***"
	ewarn
	ebeep 10
	epause 20

	ewarn
	ewarn "*** NOTICE! NOTICE! NOTICE! NOTICE! NOTICE! NOTICE! NOTICE! NOTICE! ***"
	ewarn
	ewarn "Support for the bacula all-in-one init script has been removed from"
	ewarn "this release -- if you were previously using the all-in-one init"
	ewarn "script, please switch to using the individual init scripts now:"
	ewarn
	ewarn "- bacula-dir: bacula director       (for the central bacula server)"
	ewarn "- bacula-fd:  bacula file daemon    (for hosts to be backed up)"
	ewarn "- bacula-sd:  bacula storage daemon (for hosts storing the backup data)"
	ewarn
	ewarn "*** NOTICE! NOTICE! NOTICE! NOTICE! NOTICE! NOTICE! NOTICE! NOTICE! ***"
	ewarn
	ebeep 5
	epause 10
}
