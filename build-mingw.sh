#!/bin/sh

set -e

mkdir -p binutils-build
cd binutils-build
rm -rf *
../binutils-2.24/configure --target=x86_64-w64-mingw32 --enable-targets=x86_64-w64-mingw32,i686-w64-mingw32 \
	--with-sysroot=/jenkins-worker/mingw --prefix=/jenkins-worker/mingw
make
make install

export PATH="$PATH:/jenkins-worker/mingw/bin"
