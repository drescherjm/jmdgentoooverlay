# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-kernel/openvz-sources/openvz-sources-2.6.26.9999.ebuild,v 1.1 2008/10/14 08:20:11 pva Exp $

ETYPE="sources"

inherit kernel-2
detect_version

RC=${PVR##*_}

KV_BASE=${KV_MAJOR}.${KV_MINOR}.${KV_PATCH}
KV_MOD=${KV_FULL##*-}
KV_MAIN="${KV_BASE}-${KV_MOD}"
EGIT_PROJECT="linux-${KV_FULL}"
EGIT_REPO_URI="git://git.openvz.org/pub/linux-${KV_MAIN}"
EGIT_BRANCH="master"

inherit git

HOMEPAGE="http://openvz.org/"
DESCRIPTION="OpenVZ 26 git"

IUSE=""
KEYWORDS=""
K_NOUSENAME="yes"
K_PREPATCHED="yes"

src_unpack() {
	git_src_unpack

	cd "${EGIT_STORE_DIR}/${EGIT_PROJECT}"
	local last_commit_abbrev=$(git log -n 1 --no-color --pretty='format:%h')

	EXTRAVERSION="-${KV_MOD}.git-${last_commit_abbrev}"

	S=${WORKDIR}/${EGIT_PROJECT}

	cd "${S}"

	unpack_set_extraversion
}
