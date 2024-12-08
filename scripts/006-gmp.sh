#!/bin/sh -e

WINE_LIBS=${WINE_LIBS:=$(PWD)/../target}

PATH=${WINE_LIBS}/bin:${PATH}

VER=6.3.0
PKGNAME=gmp

if [ ! -f ${PKGNAME}-${VER}.tar.xz ]; then wget --continue https://gmplib.org/download/gmp/${PKGNAME}-${VER}.tar.xz; fi

rm -Rf ${PKGNAME}-${VER} && tar xf ${PKGNAME}-${VER}.tar.xz && cd ${PKGNAME}-${VER}

if [ -f ../../patches/${PKGNAME}.patch ]; then cat ../../patches/${PKGNAME}.patch | patch -p1; fi

CC="clang -arch x86_64" \
ABI=64 \
./configure \
--prefix="$WINE_LIBS" \
--build="x86_64-apple-darwin" \
--disable-cxx \
--enable-shared \
--disable-static


PROCS="$(sysctl -n hw.ncpu 2>/dev/null)"
${MAKE:-make} -j $PROCS

mkdir -p ${WINE_LIBS}/include
cp gmp.h ${WINE_LIBS}/include
mkdir -p ${WINE_LIBS}/lib
cp -P .libs/*.dylib ${WINE_LIBS}/lib
mkdir -p ${WINE_LIBS}/lib/pkgconfig
cp gmp.pc ${WINE_LIBS}/lib/pkgconfig
