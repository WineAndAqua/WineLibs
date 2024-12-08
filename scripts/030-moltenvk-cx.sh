#!/bin/sh -e

WINE_LIBS=${WINE_LIBS:=$(PWD)/../target}

PATH=${WINE_LIBS}/bin:${PATH}

if [ ! -d crossover-sources-20241028 ]; then
    if [ ! -f crossover-sources-20241028.tar.gz ]; then exit 1; fi
    tar xf crossover-sources-20241028.tar.gz
    mv sources crossover-sources-20241028
fi

if [ ! -d moltenvk ]; then
    cp -R crossover-sources-20241028/moltenvk .

    if [ -f ../patches/moltenvk-cx.patch ]; then cd moltenvk; cat ../../patches/moltenvk-cx.patch | patch -p1; cd ..; fi
fi

cd moltenvk

./fetchDependencies --macos

PROCS="$(sysctl -n hw.ncpu 2>/dev/null)"
${MAKE:-make} -j $PROCS macos

mkdir -p ${WINE_LIBS}/lib
cp -p Package/Latest/MoltenVK/dynamic/dylib/macOS/libMoltenVK.dylib ${WINE_LIBS}/lib
