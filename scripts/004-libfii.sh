#!/bin/sh -e

WINE_LIBS=${WINE_LIBS:=$(PWD)/../target}

PATH=${WINE_LIBS}/bin:${PATH}

VER=3.4.5
PKGNAME=libffi

if [ ! -f ${PKGNAME}-${VER}.tar.gz ]; then wget --continue https://github.com/libffi/libffi/releases/download/v${VER}/${PKGNAME}-${VER}.tar.gz; fi

rm -Rf ${PKGNAME}-${VER} && tar xf ${PKGNAME}-${VER}.tar.gz && cd ${PKGNAME}-${VER}

if [ -f ../../patches/${PKGNAME}.patch ]; then cat ../../patches/${PKGNAME}.patch | patch -p1; fi

CC="clang -arch x86_64" \
ABI=64 \
./configure \
--prefix="$WINE_LIBS" \
--build="x86_64-apple-darwin" \
--enable-shared \
--disable-static

PROCS="$(sysctl -n hw.ncpu 2>/dev/null)"
${MAKE:-make} -j $PROCS


mkdir -p ${WINE_LIBS}/include
cp x86_64-apple-darwin/include/*.h ${WINE_LIBS}/include
mkdir -p ${WINE_LIBS}/lib
cp -P x86_64-apple-darwin/.libs/*.dylib ${WINE_LIBS}/lib
cp x86_64-apple-darwin/libffi.pc ${WINE_LIBS}/lib/pkgconfig
