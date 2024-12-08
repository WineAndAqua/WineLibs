#!/bin/sh -e

WINE_LIBS=${WINE_LIBS:=$(PWD)/../target}

PATH=${WINE_LIBS}/bin:${PATH}

VER=3.10
PKGNAME=nettle

if [ ! -f ${PKGNAME}-${VER}.tar.gz ]; then wget --continue https://ftp.gnu.org/gnu/nettle/${PKGNAME}-${VER}.tar.gz; fi

rm -Rf ${PKGNAME}-${VER} && tar xf ${PKGNAME}-${VER}.tar.gz && cd ${PKGNAME}-${VER}

if [ -f ../../patches/${PKGNAME}.patch ]; then cat ../../patches/${PKGNAME}.patch | patch -p1; fi

CC="clang -arch x86_64" \
CFLAGS="-I${WINE_LIBS}/include" \
LDFLAGS="-L${WINE_LIBS}/lib" \
./configure \
--prefix="$WINE_LIBS" \
--build="x86_64-apple-darwin" \
--disable-documentation \
--disable-openssl \
--enable-public-key \
--enable-shared \
--disable-static


PROCS="$(sysctl -n hw.ncpu 2>/dev/null)"
${MAKE:-make} -j $PROCS && ${MAKE:-make} install-headers install-pkgconfig install-shared-nettle install-shared-hogweed
