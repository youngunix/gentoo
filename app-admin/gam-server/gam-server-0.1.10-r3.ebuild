# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

GNOME_ORG_MODULE="gamin"
GNOME_TARBALL_SUFFIX="bz2"

inherit autotools flag-o-matic gnome.org

DESCRIPTION="Library providing the FAM File Alteration Monitor API"
HOMEPAGE="https://www.gnome.org/~veillard/gamin/"
SRC_URI="${SRC_URI}
	mirror://gentoo/gamin-0.1.9-freebsd.patch.bz2
	https://pkgconfig.freedesktop.org/releases/pkg-config-0.26.tar.gz" # pkg.m4 for eautoreconf

LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="~alpha amd64 arm arm64 ~hppa ~m68k ~mips ppc ppc64 ~riscv ~s390 sparc x86"
IUSE="debug"

RDEPEND=">=dev-libs/glib-2:2
	>=dev-libs/libgamin-0.1.10
	!app-admin/fam
	!<app-admin/gamin-0.1.10"

DEPEND="${RDEPEND}"

src_prepare() {
	mv -vf "${WORKDIR}"/pkg-config-*/pkg.m4 "${WORKDIR}"/ || die

	# Fix compile warnings; bug #188923
	eapply "${WORKDIR}/gamin-0.1.9-freebsd.patch"

	# Fix file-collision due to shared library, upstream bug #530635
	eapply "${FILESDIR}/${PN}-0.1.10-noinst-lib.patch"

	# Fix compilation with latest glib, bug #382783
	eapply "${FILESDIR}/${PN}-0.1.10-G_CONST_RETURN-removal.patch"

	# Fix crosscompilation issues, bug #267604
	eapply "${FILESDIR}/${PN}-0.1.10-crosscompile-fix.patch"

	# Enable linux specific features on armel, upstream bug #588338
	eapply "${FILESDIR}/${P}-armel-features.patch"

	# Fix deadlocks with glib-2.32, bug #413331, upstream #667230
	eapply "${FILESDIR}/${P}-ih_sub_cancel-deadlock.patch"

	# Drop DEPRECATED flags
	sed -i -e 's:-DG_DISABLE_DEPRECATED:$(NULL):g' server/Makefile.am || die

	sed -i \
		-e 's:AM_CONFIG_HEADER:AC_CONFIG_HEADERS:' \
		-e 's:AM_PROG_CC_STDC:AC_PROG_CC:' \
		configure.in || die #466948

	eapply_user

	# autoconf is required as the user-cflags patch modifies configure.in
	# however, elibtoolize is also required, so when the above patch is
	# removed, replace the following call with a call to elibtoolize
	AT_M4DIR="${WORKDIR}" eautoreconf
}

src_configure() {
	# Solaris' patchs adds this to configure, but it conflicts with
	# Gentoo's FreeBSD patch.
	[[ ${CHOST} == *-solaris* ]] && append-libs socket nsl

	if ! has_version virtual/pkgconfig; then
		export DAEMON_CFLAGS="-I${EPREFIX}/usr/include/glib-2.0 -I${EPREFIX}/usr/$(get_libdir)/glib-2.0/include"
		export DAEMON_LIBS="-lglib-2.0"
	fi

	econf \
		--disable-debug \
		--disable-libgamin \
		--without-python \
		$(use_enable kernel_linux inotify) \
		$(use_enable debug debug-api)
}

src_install() {
	emake DESTDIR="${D}" install
}
