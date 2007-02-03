# Copyright 1999-2004 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-emulation/vmware-workstation/vmware-workstation-5.0_beta1.ebuild,v 1.1 2004/11/30 00:53:14 jhuebel Exp $

# Unlike many other binary packages the user doesn't need to agree to a licence
# to download VMWare. The agreeing to a licence is part of the configure step
# which the user must run manually.

inherit eutils

S=${WORKDIR}/vmware-distrib
NP="VMware-workstation-e.x.p-11608"
DESCRIPTION="Emulate a complete PC on your PC without the usual performance overhead of most emulators"
HOMEPAGE="http://www.vmware.com/products/desktop/ws_features.html"
SRC_URI="${NP}.tar.gz
 mirror://gentoo/vmware.png"

LICENSE="vmware"
IUSE=""
SLOT="0"
KEYWORDS="~x86 ~amd64"
RESTRICT="nostrip fetch"

DEPEND="virtual/libc
 virtual/x11
 virtual/os-headers
 >=dev-lang/perl-5
 sys-apps/pciutils"

src_install() {
 dodir /opt/vmware/bin
 cp -a bin/* ${D}/opt/vmware/bin/
 chmod u+s ${D}/opt/vmware/bin/vmware || die
 chmod u+s ${D}/opt/vmware/bin/vmware-ping || die

 dodir /opt/vmware/lib
 cp -dr lib/* ${D}/opt/vmware/lib/

 chmod u+s ${D}/opt/vmware/lib/bin/vmware-vmx || die

 # Since with Gentoo we compile everthing it doesn't make sense to keep
 # the precompiled modules arround. Saves about 4 megs of disk space too.
 rm -rf ${D}/opt/vmware/lib/modules/binary

 dodir /opt/vmware/doc
 cp -a doc/* ${D}/opt/vmware/doc/

	dodir /opt/vmware/man/
	cp -a man/* ${D}/opt/vmware/man/

	# vmware service loader
	exeinto /etc/init.d
	newexe ${FILESDIR}/vmware.rc vmware || die

	# vmware enviroment
	insinto /etc/env.d
	doins ${FILESDIR}/90vmware || die

	dodir /etc/vmware/
	cp -a etc/* ${D}/etc/vmware/

	dodir /etc/vmware/init.d
	dodir /etc/vmware/init.d/rc0.d
	dodir /etc/vmware/init.d/rc1.d
	dodir /etc/vmware/init.d/rc2.d
	dodir /etc/vmware/init.d/rc3.d
	dodir /etc/vmware/init.d/rc4.d
	dodir /etc/vmware/init.d/rc5.d
	dodir /etc/vmware/init.d/rc6.d
	cp -a installer/services.sh ${D}/etc/vmware/init.d/vmware || die

	# This is to fix a problem where if someone merges vmware and then
	# before configuring vmware they upgrade or re-merge the vmware
	# package which would rmdir the /etc/vmware/init.d/rc?.d directories.
	keepdir /etc/vmware/init.d/rc{0,1,2,3,4,5,6}.d

	# A simple icon I made
	dodir /opt/vmware/lib/icon
	insinto /opt/vmware/lib/icon
	doins ${DISTDIR}/vmware.png || die
	insinto /usr/share/pixmaps
	doins ${DISTDIR}/vmware.png || die

	make_desktop_entry vmware "VMWare Workstation" vmware.png

	dodir /usr/bin
	dosym /opt/vmware/bin/vmware /usr/bin/vmware

	# Questions:
	einfo "Adding answers to /etc/vmware/locations"
	locations="${D}/etc/vmware/locations"
	echo "answer BINDIR /opt/vmware/bin" >> ${locations}
	echo "answer LIBDIR /opt/vmware/lib" >> ${locations}
	echo "answer MANDIR /opt/vmware/man" >> ${locations}
	echo "answer DOCDIR /opt/vmware/doc" >> ${locations}
	echo "answer RUN_CONFIGURATOR no" >> ${locations}
	echo "answer INITDIR /etc/vmware/init.d" >> ${locations}
	echo "answer INITSCRIPTSDIR /etc/vmware/init.d" >> ${locations}
}

pkg_preinst() {
	# This must be done after the install to get the mtimes on each file
	# right. This perl snippet gets the /etc/vmware/locations file code:
	# perl -e "@a = stat('bin/vmware'); print \$a[9]"
	# The above perl line and the find line below output the same thing.
	# I would think the find line is faster to execute.
	# find /opt/vmware/bin/vmware -printf %T@

	#Note: it's a bit weird to use ${D} in a preinst script but it should work
	#(drobbins, 1 Feb 2002)

	einfo "Generating /etc/vmware/locations file."
	d=`echo ${D} | wc -c`
	for x in `find ${D}/opt/vmware ${D}/etc/vmware` ; do
		x="`echo ${x} | cut -c ${d}-`"
		if [ -d ${D}/${x} ] ; then
			echo "directory ${x}" >> ${D}/etc/vmware/locations
		else
			echo -n "file ${x}" >> ${D}/etc/vmware/locations
			if [ "${x}" == "/etc/vmware/locations" ] ; then
				echo "" >> ${D}/etc/vmware/locations
			elif [ "${x}" == "/etc/vmware/not_configured" ] ; then
				echo "" >> ${D}/etc/vmware/locations
			else
				echo -n " " >> ${D}/etc/vmware/locations
				#perl -e "@a = stat('${D}${x}'); print \$a[9]" >> ${D}/etc/vmware/locations
				find ${D}${x} -printf %T@ >> ${D}/etc/vmware/locations
				echo "" >> ${D}/etc/vmware/locations
			fi
		fi
	done
}

pkg_config() {
 # In case pkg_config() ends up being the defacto standard for
 # configuring packages (malverian <malverian@gentoo.org>)

 einfo "Running /opt/vmware/bin/vmware-config.pl"
 /opt/vmware/bin/vmware-config.pl
}

pkg_postinst() {
 # This is to fix the problem where the not_configured file doesn't get
 # removed when the configuration is run. This doesn't remove the file
 # It just tells the vmware-config.pl script it can delete it.
 einfo "Updating /etc/vmware/locations"
 for x in /etc/vmware/._cfg????_locations ; do
  if [ -f $x ] ; then
   cat $x >> /etc/vmware/locations
   rm $x
  fi
 done

 einfo
 einfo "You need to run /opt/vmware/bin/vmware-config.pl to complete the install."
 einfo
 einfo "For VMware Add-Ons just visit"
 einfo "http://www.vmware.com/download/downloadaddons.html"
 einfo
 einfo "After configuring, type 'vmware' to launch"
 einfo
 einfo "Also note that when you reboot you should run:"
 einfo "/etc/init.d/vmware start"
 einfo "before trying to run vmware.  Or you could just add"
 einfo "it to the default run level:"
 einfo "rc-update add vmware default"
 echo
 #ewarn "For users of glibc-2.3.x, vmware-nat support is *still* broken on 2.6.x"
}

pkg_postrm() {
 einfo
 einfo "To remove all traces of vmware you will need to remove the files"
 einfo "in /etc/vmware/, /etc/init.d/vmware, /lib/modules/*/misc/vm*.o,"
 einfo "and .vmware/ in each users home directory. Don't forget to rmmod the"
 einfo "vm* modules, either."
 einfo
}
