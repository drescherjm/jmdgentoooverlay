# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/gnome-extra/deskbar-applet/deskbar-applet-2.14.1.1.ebuild,v 1.4 2006/05/18 14:38:25 tcort Exp $

inherit eutils autotools

S=${WORKDIR}/${P}/src
DESCRIPTION="Sun ZFS, ported using FUSE"
HOMEPAGE="http://www.wizy.org/wiki/ZFS_on_FUSE"
SRC_URI="http://download.berlios.de/zfs-fuse/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86"
IUSE=""

RDEPEND="
	virtual/libc
	"
DEPEND="${RDEPEND}
	dev-util/scons
	"

src_unpack()
	{
	unpack ${A}
	cd ${S}
	#epatch ${FILESDIR}/${P}-chroot.patch
	}

src_compile()
	{
	#pwd
	#local myconf
	#use debug && myconf="${myconf} --enable-debug"
	#econf ${myconf} || die "Configuration failed"
	#econf || die "Configuration failed"
	#for file in Makefile fs/Makefile libnpfs/Makefile
	#do
	#	echo CFLAGS="-Wall -I ../include -DSYSNAME=\$(SYSNAME) ${CFLAGS}" >> $file
	#done
	scons || die "Make failed"
	einfo
	einfo "Running tests..."
	einfo
	cd cmd/ztest/
	mkdir tmp
	#./runtest.sh -T 7200 -f `pwd`/tmp/
	./runtest.sh -T 20 -f `pwd`/tmp/
	rm ./tmp/ztest*
	einfo
	einfo "Tests done, quitting now..."
	einfo
	die "Tests done"
	}

src_install()
	{
	# library
	#dolib.a libnpfs/libnpfs.a

	# executables
	#for file in `ls -1 fs/*fs fs/*fs2`
	#do
	#	dobin $file
	#done

	# headers
	insopts -m0644
	#insinto /usr/include
	#doins include/npfs.h
	#fowners root:root /usr/include/npfs.h

	# docs
	#dodoc {AUTHORS,ChangeLog,COPYING,NEWS,README}
	}
