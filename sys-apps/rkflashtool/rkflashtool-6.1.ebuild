# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit toolchain-funcs

DESCRIPTION="Tool for flashing Rockchip devices"
HOMEPAGE="https://sourceforge.net/projects/rkflashtool/"
SRC_URI="https://downloads.sourceforge.net/project/${PN}/${P}/${P}-src.tar.xz"
S="${WORKDIR}/${P}-src"

LICENSE="BSD-2"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="virtual/libusb:1"
DEPEND="${RDEPEND}"

src_prepare() {
	default
	cp "${FILESDIR}"/${P}-missing-version.h version.h || die
	sed -i -e "s/CC	=/CC ?=/"\
		-e "s/CFLAGS	=/CFLAGS ?=/"\
		-e "s/LDFLAGS	=/LDFLAGS ?=/" Makefile || die
	tc-export CC
}

src_install() {
	dodoc README
	dobin rkcrc  rkflashtool rkmisc  rkpad  rkparameters  rkparametersblock  rkunpack  rkunsign
}
