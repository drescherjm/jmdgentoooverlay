# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header $

inherit eutils qt3 pax-utils

MY_P=VirtualBox_${PV}_Linux_${ARCH}.run

DESCRIPTION="Softwarefamily of powerful x86 virtualization"
HOMEPAGE="http://www.virtualbox.org/"
SRC_URI="amd64? ( http://www.virtualbox.org/download/${PV}/${MY_P} )
	x86? ( http://www.virtualbox.org/download/${PV}/${MY_P} )"

LICENSE="PUEL"
SLOT="0"
KEYWORDS="~amd64 x86"
IUSE="additions nowrapper sdk"

RDEPEND="!app-emulation/virtualbox
	~app-emulation/virtualbox-modules-${PV}
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
	=virtual/libstdc++-3.3
	sdk? ( dev-libs/libIDL )"

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
	cd "${S}"

	# desktop entry
	insinto /usr/share/pixmaps
	newins VBox.png virtualbox.png
	insinto /usr/share/applications
	newins VirtualBox.desktop virtualbox.desktop
	dosed -e "10d" /usr/share/applications/virtualbox.desktop
	dosed -e "5d" /usr/share/applications/virtualbox.desktop
	dosed -e "s/VirtualBox/virtualbox/" /usr/share/applications/virtualbox.desktop
	dosed -e "s/VBox.png/virtualbox.png/" /usr/share/applications/virtualbox.desktop

	insinto /opt/VirtualBox
	doins UserManual.pdf
	if use additions; then
		doins -r additions
	fi
	if use sdk; then
		doins -r sdk
		fperms 0755 /opt/VirtualBox/sdk/bin/xpidl
		pax-mark -m "${D}"/opt/VirtualBox/sdk/bin/xpidl
		make_wrapper xpidl "sdk/bin/xpidl" "/opt/VirtualBox" "/opt/VirtualBox" "/usr/bin"
	fi

	rm -rf src sdk tst* UserManual.pdf rdesktop-vrdp.tar.gz deffiles install.sh \
	routines.sh runlevel.sh vboxdrv.sh VBox.sh VBox.png kchmviewer additions \
	VirtualBox.desktop VirtualBox.chm VirtualBox.tar.bz2 vditool LICENSE

	doins -r *
	for each in VBox{Manage,SDL,SVC,XPCOMIPCD,VRDP} VirtualBox ; do
		fperms 0755 /opt/VirtualBox/${each}
		pax-mark -m "${D}"/opt/VirtualBox/${each}
	done

	if use nowrapper ; then
		make_wrapper vboxsvc "./VBoxSVC" "/opt/VirtualBox" "/opt/VirtualBox" "/usr/bin"
		make_wrapper virtualbox "./VirtualBox" "/opt/VirtualBox" "/opt/VirtualBox" "/usr/bin"
		make_wrapper vboxmanage "./VBoxManage" "/opt/VirtualBox" "/opt/VirtualBox" "/usr/bin"
		make_wrapper vboxsdl "./VBoxSDL" "/opt/VirtualBox" "/opt/VirtualBox" "/usr/bin"
		make_wrapper vboxvrdp "./VBoxVRDP" "/opt/VirtualBox" "/opt/VirtualBox" "/usr/bin"
	else
		exeinto /opt/VirtualBox
		newexe "${FILESDIR}/${PN}-wrapper" "wrapper.sh"
		dosym /opt/VirtualBox/wrapper.sh /usr/bin/virtualbox
		dosym /opt/VirtualBox/wrapper.sh /usr/bin/vboxmanage
		dosym /opt/VirtualBox/wrapper.sh /usr/bin/vboxsdl
		dosym /opt/VirtualBox/wrapper.sh /usr/bin/vboxvrdp
	fi
}

pkg_postinst() {
	elog ""
	if use nowrapper; then
		elog "In order to launch VirtualBox you need to start the"
		elog "VirtualBox XPCom Server first, with:"
		elog "vboxsvc --daemonize && virtualbox"
	else
		elog "To launch VirtualBox just type: \"virtualbox\""
	fi
	elog ""
	elog "You must be in the vboxusers group to use VirtualBox,"
	elog "\"vditool\" is now deprecated, use \"VBoxManage\" instead."
	elog ""
}
