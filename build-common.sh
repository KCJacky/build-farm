#!/bin/sh

set -e

. ./build-common

# ----------------------------------------------------------------------------------------------------------------
#  CMake
# ----------------------------------------------------------------------------------------------------------------

mkdir -p cmake-build
cd cmake-build
rm -rf *
../cmake-2.8.12.2/configure --prefix=$INSTALL_ROOT
make -j "$NUM_CPUS"
make install
cd ..

mkdir -p $INSTALL_ROOT/cmake
cp -f mingw32.cmake $INSTALL_ROOT/cmake/
cp -f mingw64.cmake $INSTALL_ROOT/cmake/

# ----------------------------------------------------------------------------------------------------------------
#  gperf
# ----------------------------------------------------------------------------------------------------------------

mkdir -p gperf-build
cd gperf-build
rm -rf *
../gperf-3.0.4/configure --prefix=$INSTALL_ROOT
make -j "$NUM_CPUS"
make install
cd ..

# ----------------------------------------------------------------------------------------------------------------
#  NASM
# ----------------------------------------------------------------------------------------------------------------

mkdir -p nasm-build
mkdir -p nasm-build/rdoff
mkdir -p nasm-build/lib
cd nasm-build
rm -rf *
rm -f ../nasm-2.11.02/config.h
../nasm-2.11.02/configure --prefix=$INSTALL_ROOT
echo "#include \"../config.h\"\n" > rdoff/config.h
ln -fs ../nasm-build/config.h ../nasm-2.11.02/config.h
make -j "$NUM_CPUS"
make strip
make install
rm -f ../nasm-2.11.02/config.h
cd ..
