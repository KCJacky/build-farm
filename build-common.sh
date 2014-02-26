#!/bin/sh

set -e

. ./build-common

# ----------------------------------------------------------------------------------------------------------------
#  CMake
# ----------------------------------------------------------------------------------------------------------------

mkdir -p cmake-build
cd cmake-build
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
../gperf-3.0.4/configure --prefix=$INSTALL_ROOT
make -j "$NUM_CPUS"
make install
cd ..
