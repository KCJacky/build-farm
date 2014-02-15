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

mkdir -p mingw-build
cd mingw-build
rm -rf *
../mingw-w64-v3.1.0/configure --build=`../binutils-2.24/config.guess` --host=x86_64-w64-mingw32 \
	--prefix=/jenkins-worker/mingw/x86_64-w64-mingw32 --without-crt
make install
ln -fs /jenkins-worker/mingw/x86_64-w64-mingw32 /jenkins-worker/mingw/mingw
mkdir -p /jenkins-worker/mingw/x86_64-w64-mingw32/lib
ln -s /jenkins-worker/mingw/x86_64-w64-mingw32/lib /jenkins-worker/mingw/x86_64-w64-mingw32/lib64

