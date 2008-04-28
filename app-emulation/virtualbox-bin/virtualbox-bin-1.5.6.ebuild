# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-emulation/virtualbox-bin/virtualbox-bin-1.5.4.ebuild,v 1.1 2008/01/05 17:53:52 jokey Exp $

inherit eutils fdo-mime qt3 pax-utils

MY_P=VirtualBox_${PV}-1_Linux_${ARCH}.run

DESCRIPTION="Softwarefamily of powerful x86 virtualization"
HOMEPAGE="http://www.virtualbox.org/"
SRC_URI="amd64? ( http://www.virtualbox.org/download/${PV}/VirtualBox_${PV}-1_Linux_amd64.run )
	x86? ( http://www.virtualbox.org/download/${PV}/VirtualBox_${PV}-1_Linux_x86.run )"

LICENSE="PUEL"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="additions chm sdk"

RDEPEND="!app-emulation/virtualbox
	!app-emulation/virtualbox-additions
	>=app-emulation/virtualbox-modules-${PV}
	virtual/xft
	x11-libs/libXi
	x11-libs/libX11
	x11-libs/libXft
	x11-libs/libXtst
	x11-libs/libXext
	x11-libs/libXt
	x11-libs/libICE
	x11-libs/libSM
	x11-libs/libXrender
	x11-libs/libXrandr
	x11-libs/libXau
	x11-libs/libXcursor
	x11-libs/libXdmcp
	x11-libs/libXfixes
	dev-libs/libxml2
	media-libs/libsdl
	media-libs/libmng
	media-libs/jpeg
	media-libs/libpng
	media-libs/freetype
	media-libs/fontconfig
	$(qt_min_version 3.3.5)
	sys-apps/usermode-utilities
	net-misc/bridge-utils
	x86? ( =virtual/libstdc++-3.3 )
	sdk? ( dev-libs/libIDL )
	chm? ( app-doc/kchmviewer )"

S=${WORKDIR}

RESTRICT="primaryuri"

pkg_setup() {
	# The VBoxSDL frontend needs media-libs/libsdl compiled
	# with USE flag X enabled (bug #177335)
	if ! built_with_use media-libs/libsdl X; then
		eerror "media-libs/libsdl was compiled without the \"X\" USE flag enabled."
		eerror "Please re-emerge media-libs/libsdl with USE=\"X\"."
		die "media-libs/libsdl should be compiled with the \"X\" USE flag."
	fi

	check_license
}

src_unpack() {
	unpack_makeself ${MY_P}
	unpack ./VirtualBox.tar.bz2
}

src_install() {

	# desktop entry
	newicon VBox.png virtualbox.png
	newmenu "${FILESDIR}"/${PN}.desktop virtualbox.desktop

	# create virtualbox configurations files
	insinto /etc/vbox
	newins "${FILESDIR}/${PN}-config" vbox.cfg
	newins "${FILESDIR}/${PN}-interfaces" interfaces

	insinto /opt/VirtualBox
	doins UserManual.pdf

	if use additions; then
		doins -r additions
	fi
	if use sdk; then
		doins -r sdk
		fowners root:vboxusers /opt/VirtualBox/sdk/bin/xpidl
		fperms 0750 /opt/VirtualBox/sdk/bin/xpidl
		pax-mark -m "${D}"/opt/VirtualBox/sdk/bin/xpidl
	fi
	if use chm; then
		doins *.chm
		dosym /usr/bin/kchmviewer /opt/VirtualBox/kchmviewer
	fi

	rm -rf src sdk tst* rdesktop-vrdp.tar.gz deffiles install.sh routines.sh \
	runlevel.sh vboxdrv.sh VBox.sh VBox.png kchmviewer additions VirtualBox.desktop \
	VirtualBox.tar.bz2 vboxnet.sh LICENSE VirtualBox.chm VirtualBoxAPI.chm \
	VBoxSysInfo.sh

	doins -r *
	for each in VBox{Manage,SDL,SVC,XPCOMIPCD,VRDP,Tunctl} VirtualBox ; do
		fowners root:vboxusers /opt/VirtualBox/${each}
		fperms 0750 /opt/VirtualBox/${each}
		pax-mark -m "${D}"/opt/VirtualBox/${each}
	done

	exeinto /opt/VirtualBox
	newexe "${FILESDIR}/${PN}-wrapper" "VBox.sh" || die
	fowners root:vboxusers /opt/VirtualBox/VBox.sh
	fperms 0750 /opt/VirtualBox/VBox.sh
	fowners root:vboxusers /opt/VirtualBox/VBoxAddIF.sh
	fperms 0750 /opt/VirtualBox/VBoxAddIF.sh

	dosym /opt/VirtualBox/VBox.sh /usr/bin/VirtualBox
	dosym /opt/VirtualBox/VBox.sh /usr/bin/VBoxManage
	dosym /opt/VirtualBox/VBox.sh /usr/bin/VBoxSDL
	dosym /opt/VirtualBox/VBox.sh /usr/bin/VBoxVRDP
	dosym /opt/VirtualBox/VBoxTunctl /usr/bin/VBoxTunctl
	dosym /opt/VirtualBox/VBoxAddIF.sh /usr/bin/VBoxAddIF
	dosym /opt/VirtualBox/VBoxAddIF.sh /usr/bin/VBoxDeleteIF
}

pkg_postinst() {
	fdo-mime_desktop_database_update
	elog ""
	elog "To launch VirtualBox just type: \"VirtualBox\""
	elog "You must be in the vboxusers group to use VirtualBox"
	elog ""
}

pkg_postrm() {
	fdo-mime_desktop_database_update
}
