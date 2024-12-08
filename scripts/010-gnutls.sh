#!/bin/sh -e

WINE_LIBS=${WINE_LIBS:=$(PWD)/../target}

PATH=${WINE_LIBS}/bin:${PATH}

VER=3.8.4
PKGNAME=gnutls

if [ ! -f ${PKGNAME}-${VER}.tar.xz ]; then wget --continue https://www.gnupg.org/ftp/gcrypt/gnutls/v3.8/${PKGNAME}-${VER}.tar.xz; fi

rm -Rf ${PKGNAME}-${VER} && tar xf ${PKGNAME}-${VER}.tar.xz && cd ${PKGNAME}-${VER}

if [ -f ../../patches/${PKGNAME}.patch ]; then cat ../../patches/${PKGNAME}.patch | patch -p1; fi

CC="clang -arch x86_64" \
CFLAGS="-I${WINE_LIBS}/include" \
LDFLAGS="-L${WINE_LIBS}/lib" \
ac_cv_prog_AWK=/usr/bin/awk \
./configure --prefix="$WINE_LIBS" \
--build="x86_64-apple-darwin" \
--disable-dependency-tracking \
--disable-doc \
--disable-heartbeat-support \
--disable-libdane \
--disable-silent-rules \
--enable-shared \
--disable-static \
--disable-manpages \
--with-included-libtasn1 \
--with-included-unistring \
--disable-openssl-compatibility \
--without-p11-kit \
--without-brotli \
--disable-guile \
--disable-cxx \
--without-idn \
--without-zstd \
--disable-tools \
--without-tpm \
--without-tpm2


PROCS="$(sysctl -n hw.ncpu 2>/dev/null)"
${MAKE:-make} -j $PROCS

mkdir -p ${WINE_LIBS}/include/gnutls
cp lib/includes/gnutls/*.h ${WINE_LIBS}/include/gnutls
mkdir -p ${WINE_LIBS}/lib
cp -P lib/.libs/*.dylib ${WINE_LIBS}/lib
cp lib/gnutls.pc ${WINE_LIBS}/lib/pkgconfig
