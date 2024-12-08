#!/bin/sh -e

WINE_LIBS=${WINE_LIBS:=$(PWD)/../target}

PATH=${WINE_LIBS}/bin:${PATH}

VER=0.22.5
PKGNAME=gettext

if [ ! -f ${PKGNAME}-${VER}.tar.gz ]; then wget --continue https://ftp.gnu.org/pub/gnu/gettext/${PKGNAME}-${VER}.tar.gz; fi

rm -Rf ${PKGNAME}-${VER} && tar xfz ${PKGNAME}-${VER}.tar.gz && cd ${PKGNAME}-${VER}

if [ -f ../../patches/${PKGNAME}.patch ]; then cat ../../patches/${PKGNAME}.patch | patch -p1; fi

CC="clang -arch x86_64" \
ac_cv_prog_AWK=/usr/bin/awk \
ac_cv_path_GMSGFMT=: \
ac_cv_path_GREP=/usr/bin/grep \
ac_cv_path_MSGFMT=: \
ac_cv_path_MSGMERGE=: \
ac_cv_path_SED=/usr/bin/sed \
ac_cv_path_XGETTEXT=: \
./configure --prefix="$WINE_LIBS" \
--build="x86_64-apple-darwin" \
--enable-shared \
--disable-static \
--without-xz \
--without-bzip2 \
--without-git \
--without-cvs \
--without-emacs \
--disable-openmp \
--disable-libasprintf \
--without-libunistring \
--without-libtextstyle \
--disable-csharp \
--disable-java


PROCS="$(sysctl -n hw.ncpu 2>/dev/null)"
${MAKE:-make} -j $PROCS

mkdir -p ${WINE_LIBS}/include
cp gettext-runtime/intl/libintl.h ${WINE_LIBS}/include
mkdir -p ${WINE_LIBS}/lib
cp -P gettext-runtime/intl/.libs/*.dylib ${WINE_LIBS}/lib
