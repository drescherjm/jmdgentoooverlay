# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-emulation/virtualbox-ose/virtualbox-ose-9999.ebuild,v 1.10 2009/10/03 17:09:57 patrick Exp $

EAPI=1

inherit eutils fdo-mime flag-o-matic linux-mod pax-utils qt4 subversion toolchain-funcs

DESCRIPTION="Softwarefamily of powerful x86 virtualization"
HOMEPAGE="http://www.virtualbox.org/"
ESVN_REPO_URI="http://www.virtualbox.org/svn/vbox/trunk"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS=""
IUSE="alsa headless pulseaudio python +qt4 sdk"

RDEPEND="!app-emulation/virtualbox-bin
	!app-emulation/virtualbox-ose-additions
	!app-emulation/virtualbox-modules
	dev-libs/libIDL
	>=dev-libs/libxslt-1.1.19
	dev-libs/xalan-c
	dev-libs/xerces-c
	net-misc/curl
	sys-libs/libcap
	!headless? (
		qt4? ( x11-libs/qt-gui:4 x11-libs/qt-core:4 x11-libs/qt-opengl:4 )
		x11-libs/libXcursor
		media-libs/libsdl
		x11-libs/libXt
		media-libs/mesa )"
DEPEND="${RDEPEND}
	>dev-util/kbuild-0.1.5
	>=dev-lang/yasm-0.6.2
	sys-devel/bin86
	sys-devel/dev86
	sys-power/iasl
	media-libs/libpng
	>=media-libs/alsa-lib-1.0.13
	pulseaudio? ( media-sound/pulseaudio )
	python? ( >=dev-lang/python-2.3 )"
# sys-apps/hal is required at runtime (bug #197541)
RDEPEND="${RDEPEND}
	sys-apps/usermode-utilities
	net-misc/bridge-utils
	sys-apps/hal"

BUILD_TARGETS="all"
MODULE_NAMES="vboxdrv(misc:${S}/out/linux.${ARCH}/release/bin/src:${S}/out/linux.${ARCH}/release/bin/src)"

pkg_setup() {

	#epatch_user
	
	# The VBoxSDL frontend needs media-libs/libsdl compiled
	# with USE flag X enabled (bug #177335)
	if ! built_with_use media-libs/libsdl X; then
		eerror "media-libs/libsdl was compiled without the \"X\" USE flag enabled."
		eerror "Please re-emerge media-libs/libsdl with USE=\"X\"."
		die "media-libs/libsdl should be compiled with the \"X\" USE flag."
	fi

	linux-mod_pkg_setup
	BUILD_PARAMS="KERN_DIR=${KV_DIR} KERNOUT=${KV_OUT_DIR}"

	# Add the vboxusers group before src_install
	# see (bug #184504)
	enewgroup vboxusers
}

src_compile() {

	epatch_user

	local myconf
	# Don't build vboxdrv kernel module
	myconf="--disable-kmods"
	if ! use pulseaudio; then
			myconf="${myconf} --disable-pulse"
	fi
	if ! use python; then
			myconf="${myconf} --disable-python"
	fi
	if ! use alsa; then
			myconf="${myconf} --disable-alsa"
	fi
	if ! use headless; then
			if ! use qt4; then
					myconf="${myconf} --disable-qt4"
			fi
	else
			myconf="${myconf} --build-headless"
	fi

	./configure --with-gcc="$(tc-getCC)" --with-g++="$(tc-getCXX)" \
	${myconf} || die "configure failed"
	source ./env.sh

	# Force kBuild to respect C[XX]FLAGS and MAKEOPTS (bug #178529)
	# and strip all flags
	strip-flags

	MAKE="kmk" emake TOOL_GCC3_CC="$(tc-getCC)" TOOL_GCC3_CXX="$(tc-getCXX)" \
		TOOL_GCC3_AS="$(tc-getCC)" TOOL_GCC3_AR="$(tc-getAR)" \
		TOOL_GCC3_LD="$(tc-getCXX)" TOOL_GCC3_LD_SYSMOD="$(tc-getLD)" \
		TOOL_GCC3_CFLAGS="${CFLAGS}" TOOL_GCC3_CXXFLAGS="${CXXFLAGS}" \
		TOOL_YASM_AS=yasm KBUILD_PATH="${S}/kBuild" \
		all || die "kmk failed"

	linux-mod_src_compile
}

src_install() {
	linux-mod_src_install

	cd "${S}"/out/linux.${ARCH}/release/bin

	# create configuration files
	insinto /etc/vbox
	newins "${FILESDIR}/${PN}-2-config" vbox.cfg
	newins "${FILESDIR}/${PN}-interfaces" interfaces

	# symlink binaries to the shipped wrapper
	exeinto /usr/lib/${PN}
	newexe "${FILESDIR}/${PN}-2-wrapper" "VBox" || die
	fowners root:vboxusers /usr/lib/${PN}/VBox
	fperms 0750 /usr/lib/${PN}/VBox

	dosym /usr/lib/${PN}/VBox /usr/bin/VBoxManage
	dosym /usr/lib/${PN}/VBox /usr/bin/VBoxVRDP
	dosym /usr/lib/${PN}/VBox /usr/bin/VBoxHeadless
	dosym /usr/lib/${PN}/VBoxTunctl /usr/bin/VBoxTunctl

	# install binaries and libraries
	insinto /usr/lib/${PN}
	doins -r components

	if use sdk; then
		doins -r sdk
	fi

	for each in VBox{Manage,SVC,XPCOMIPCD,Tunctl} *so *r0 *gc ; do
		doins $each
		fowners root:vboxusers /usr/lib/${PN}/${each}
		fperms 0750 /usr/lib/${PN}/${each}
	done

	if use amd64; then
		doins VBoxREM2.rel
		fowners root:vboxusers /usr/lib/${PN}/VBoxREM2.rel
		fperms 0750 /usr/lib/${PN}/VBoxREM2.rel
	fi

	if ! use headless; then
			for each in VBox{SDL,Headless} ; do
				doins $each
				fowners root:vboxusers /usr/lib/${PN}/${each}
				fperms 4750 /usr/lib/${PN}/${each}
				pax-mark -m "${D}"/usr/lib/${PN}/${each}
			done

			dosym /usr/lib/${PN}/VBox /usr/bin/VBoxSDL

			if use qt4; then
				doins VirtualBox
				fowners root:vboxusers /usr/lib/${PN}/VirtualBox
				fperms 4750 /usr/lib/${PN}/VirtualBox
				pax-mark -m "${D}"/usr/lib/${PN}/VirtualBox

				dosym /usr/lib/${PN}/VBox /usr/bin/VirtualBox
			fi

			newicon "${S}"/src/VBox/Frontends/VirtualBox/images/OSE/VirtualBox_32px.png ${PN}.png
			domenu "${FILESDIR}"/${PN}.desktop
	else
			doins VBoxHeadless
			fowners root:vboxusers /usr/lib/${PN}/VBoxHeadless
			fperms 4750 /usr/lib/${PN}/VBoxHeadless
			pax-mark -m "${D}"/usr/lib/${PN}/VBoxHeadless
	fi

	insinto /usr/share/${PN}
	doins -r nls

}

pkg_postinst() {
	linux-mod_pkg_postinst
	fdo-mime_desktop_database_update
	elog "To launch VirtualBox just type: \"VirtualBox\""
	elog "You must be in the vboxusers group to use VirtualBox."
	elog ""
	elog "The last user manual is available for download at:"
	elog "http://www.virtualbox.org/download/UserManual.pdf"
	elog ""
	elog "Due to the nature of the build process, there are not"
	elog "additions available for the live ebuild"
	elog ""
}

pkg_postrm() {
	fdo-mime_desktop_database_update
}
