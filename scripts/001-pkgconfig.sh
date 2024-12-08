#!/bin/sh -e

WINE_LIBS=${WINE_LIBS:=$(PWD)/../target}

PATH=${WINE_LIBS}/bin:${PATH}

VER=0.29.2
PKGNAME=pkg-config

if [ ! -f ${PKGNAME}-${VER}.tar.gz ]; then wget --continue https://pkgconfig.freedesktop.org/releases/${PKGNAME}-${VER}.tar.gz; fi

rm -Rf ${PKGNAME}-${VER} && tar xfz ${PKGNAME}-${VER}.tar.gz && cd ${PKGNAME}-${VER}

if [ -f ../../patches/${PKGNAME}.patch ]; then cat ../../patches/${PKGNAME}.patch | patch -p1; fi

PKG_CONFIG=false \
CC="clang" \
CFLAGS="-Wno-error=int-conversion" \
./configure \
--prefix="$WINE_LIBS" \
--disable-silent-rules \
--disable-host-tool \
--with-internal-glib \
--with-pc-path=${WINE_LIBS}/lib/pkgconfig


PROCS="$(sysctl -n hw.ncpu 2>/dev/null)"
${MAKE:-make} -j $PROCS

install -d ${WINE_LIBS}/bin
install -m 755 pkg-config ${WINE_LIBS}/bin
install -d ${WINE_LIBS}/share/aclocal
install -m 644 pkg.m4 ${WINE_LIBS}/share/aclocal
