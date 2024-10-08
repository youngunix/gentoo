# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit autotools

DESCRIPTION="A configuration framework for the fvwm window manager"
HOMEPAGE="http://fvwm-themes.sourceforge.net/"
SRC_URI="https://downloads.sourceforge.net/${PN}/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 ~ppc ~ppc64 ~riscv ~sparc x86"
IUSE="gnome"

RDEPEND=">=x11-wm/fvwm-2.6.2"
DEPEND="${RDEPEND}"
BDEPEND="gnome? ( virtual/imagemagick-tools )"

PATCHES=(
	"${FILESDIR}"/${P}-gentoo.patch
	"${FILESDIR}"/${P}-posix-sort.patch
)

src_prepare() {
	default
	eautoreconf
}

src_configure() {
	econf $(use_enable gnome gnome-icons)
}

pkg_postinst() {
	fvwm-themes-config --site --reset
	fvwm-themes-menuapp --site --build-menus --remove-popup

	use gnome && fvwm-themes-images --ft-install --gnome
}
