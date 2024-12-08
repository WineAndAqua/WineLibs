#!/bin/sh -e

WINE_LIBS=${WINE_LIBS:=$(PWD)/../target}

PATH=${WINE_LIBS}/bin:${PATH}

VER=2.78.6
PKGNAME=glib

if [ ! -f ${PKGNAME}-${VER}.tar.xz ]; then wget --continue https://download.gnome.org/sources/glib/2.78/${PKGNAME}-${VER}.tar.xz; fi

rm -Rf ${PKGNAME}-${VER} && tar xf ${PKGNAME}-${VER}.tar.xz && cd ${PKGNAME}-${VER}

if [ -f ../../patches/${PKGNAME}.patch ]; then cat ../../patches/${PKGNAME}.patch | patch -p1; fi

mkdir build && cd build

echo "\
[binaries]\n\
c = 'clang'\n\
cpp = 'clang++'\n\
objc = 'clang'\n\
strip = 'strip'\n\
pkg-config = '${WINE_LIBS}/bin/pkg-config'\n\
[host_machine]\n\
system = 'darwin'\n\
cpu_family = 'x86_64'\n\
cpu = 'x86_64'\n\
endian = 'little'\n\
" > cross.ini
CC="clang" \
CXX="clang++" \
LDFLAGS="-arch x86_64 -L${WINE_LIBS}/lib" \
meson setup .. --cross-file=cross.ini \
-Dc_args="-arch x86_64 -I${WINE_LIBS}/include" \
-Dcpp_args="-arch x86_64 -I${WINE_LIBS}/include" \
-Dobjc_args="-arch x86_64" \
-Dc_link_args="-L${WINE_LIBS}/lib" \
-Dcpp_link_args="-L${WINE_LIBS}/lib" \
-Dprefix="$WINE_LIBS" \
-Dbuildtype=release \

meson compile
meson install

rm -rf ${WINE_LIBS}/share
