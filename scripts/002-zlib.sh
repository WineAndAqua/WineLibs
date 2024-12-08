#!/bin/sh -e

WINE_LIBS=${WINE_LIBS:=$(PWD)/../target}

PATH=${WINE_LIBS}/bin:${PATH}

VER=1.3.1
PKGNAME=zlib

if [ ! -f ${PKGNAME}-${VER}.tar.gz ]; then wget --continue https://www.zlib.net/fossils/${PKGNAME}-${VER}.tar.gz; fi

rm -Rf ${PKGNAME}-${VER} && tar xfz ${PKGNAME}-${VER}.tar.gz && cd ${PKGNAME}-${VER}

if [ -f ../../patches/${PKGNAME}.patch ]; then cat ../../patches/${PKGNAME}.patch | patch -p1; fi

CC="clang -arch x86_64" \
./configure --prefix="$WINE_LIBS"

PROCS="$(sysctl -n hw.ncpu 2>/dev/null)"
${MAKE:-make} -j $PROCS

mkdir -p ${WINE_LIBS}/include
cp zlib.h ${WINE_LIBS}/include
cp zconf.h ${WINE_LIBS}/include
mkdir -p ${WINE_LIBS}/lib
cp -P *.dylib ${WINE_LIBS}/lib
mkdir -p ${WINE_LIBS}/lib/pkgconfig
cp zlib.pc ${WINE_LIBS}/lib/pkgconfig
