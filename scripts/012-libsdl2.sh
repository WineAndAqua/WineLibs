#!/bin/sh -e

WINE_LIBS=${WINE_LIBS:=$(PWD)/../target}

PATH=${WINE_LIBS}/bin:${PATH}

VER=2.30.9
PKGNAME=SDL2

if [ ! -f ${PKGNAME}-${VER}.tar.gz ]; then wget --continue https://github.com/libsdl-org/SDL/releases/download/release-${VER}/${PKGNAME}-${VER}.tar.gz; fi

rm -Rf ${PKGNAME}-${VER} && tar xf ${PKGNAME}-${VER}.tar.gz && cd ${PKGNAME}-${VER}

if [ -f ../../patches/${PKGNAME}.patch ]; then cat ../../patches/${PKGNAME}.patch | patch -p1; fi

CC="clang -arch x86_64" \
CFLAGS="-I${WINE_LIBS}/include" \
LDFLAGS="-L${WINE_LIBS}/lib" \
./configure --prefix="$WINE_LIBS" \
--build="x86_64-apple-darwin" \
--enable-shared \
--disable-static \
--disable-video \
--disable-audio \
--disable-render \
--disable-sensor \
--disable-file \
--disable-misc \
--disable-locale \
--disable-loadso \
--disable-cpuinfo \
--disable-assembly \
--disable-jack \
--disable-esd \
--disable-pulseaudio \
--disable-libsamplerate \
--disable-dbus \
--disable-power \
--disable-filesystem \
--without-x


PROCS="$(sysctl -n hw.ncpu 2>/dev/null)"
${MAKE:-make} -j $PROCS

mkdir -p ${WINE_LIBS}/include/SDL2
cp include/*.h ${WINE_LIBS}/include/SDL2
mkdir -p ${WINE_LIBS}/lib
cp -P build/.libs/*.dylib ${WINE_LIBS}/lib
cp sdl2.pc ${WINE_LIBS}/lib/pkgconfig
