# Copyright 1999-2005 Gentoo Foundation
# Copyright 2005 Preston Crow
#  ( If you make changes, please add a copyright notice above, but
#    never remove an existing notice. )
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit myth-svn

DESCRIPTION="Keyboard control adjusting module for MythTV."
HOMEPAGE="http://www.mythtv.org/"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"

DEPEND=">=sys-apps/sed-4
	virtual/mythtvlibs"

setup_pro() {
	return 0
}
