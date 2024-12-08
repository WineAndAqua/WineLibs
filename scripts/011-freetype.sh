#!/bin/sh -e

WINE_LIBS=${WINE_LIBS:=$(PWD)/../target}

PATH=${WINE_LIBS}/bin:${PATH}

VER=2.13.3
PKGNAME=freetype

if [ ! -f ${PKGNAME}-${VER}.tar.xz ]; then wget --continue https://download.savannah.gnu.org/releases/freetype/${PKGNAME}-${VER}.tar.xz; fi

rm -Rf ${PKGNAME}-${VER} && tar xf ${PKGNAME}-${VER}.tar.xz && cd ${PKGNAME}-${VER}

if [ -f ../../patches/${PKGNAME}.patch ]; then cat ../../patches/${PKGNAME}.patch | patch -p1; fi

CC="clang -arch x86_64" \
CFLAGS="-I${WINE_LIBS}/include" \
LDFLAGS="-L${WINE_LIBS}/lib" \
ac_cv_prog_AWK=/usr/bin/awk \
./configure --prefix="$WINE_LIBS" \
--build="x86_64-apple-darwin" \
--enable-shared \
--disable-static \
--without-harfbuzz \
--without-brotli \
--without-librsvg \
--without-zlib \
--without-bzip2 \
--without-png


PROCS="$(sysctl -n hw.ncpu 2>/dev/null)"
${MAKE:-make} -j $PROCS

mkdir -p ${WINE_LIBS}/include/freetype2/freetype/config
cp include/ft2build.h ${WINE_LIBS}/include/freetype2
cp include/freetype/*.h ${WINE_LIBS}/include/freetype2/freetype
cp include/freetype/config/*.h ${WINE_LIBS}/include/freetype2/freetype/config
mkdir -p ${WINE_LIBS}/lib
cp -P objs/.libs/*.dylib ${WINE_LIBS}/lib
cp builds/unix/freetype2.pc ${WINE_LIBS}/lib/pkgconfig
