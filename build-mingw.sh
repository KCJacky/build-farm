#!/bin/sh

set -e

# apt-get install build-essential flex bison patch
git submodule update --init --recursive

# ----------------------------------------------------------------------------------------------------------------
#  Binutils
# ----------------------------------------------------------------------------------------------------------------

mkdir -p binutils-build
cd binutils-build
rm -rf *
../binutils-2.24/configure --target=x86_64-w64-mingw32 --enable-targets=x86_64-w64-mingw32,i686-w64-mingw32 \
	--with-sysroot=/jenkins-worker/mingw --prefix=/jenkins-worker/mingw
make
make install
cd ..

# ----------------------------------------------------------------------------------------------------------------
#  MinGW headers
# ----------------------------------------------------------------------------------------------------------------

export PATH="/jenkins-worker/mingw/bin:$PATH"

mkdir -p mingw-build
cd mingw-build
rm -rf *
../mingw-w64-v3.1.0/configure --build=`../binutils-2.24/config.guess` --host=x86_64-w64-mingw32 \
	--prefix=/jenkins-worker/mingw/x86_64-w64-mingw32 --without-crt
make install
ln -fs /jenkins-worker/mingw/x86_64-w64-mingw32 /jenkins-worker/mingw/mingw
mkdir -p /jenkins-worker/mingw/x86_64-w64-mingw32/lib
ln -s /jenkins-worker/mingw/x86_64-w64-mingw32/lib /jenkins-worker/mingw/x86_64-w64-mingw32/lib64
cd ..

# ----------------------------------------------------------------------------------------------------------------
#  GCC bootstrap
# ----------------------------------------------------------------------------------------------------------------

mkdir -p gcc-build
cd gcc-build
rm -rf *
../gcc-4.8.2/configure --target=x86_64-w64-mingw32 --enable-targets=all --with-sysroot=/jenkins-worker/mingw \
	--prefix=/jenkins-worker/mingw
make all-gcc
make install-gcc
cd ..

# ----------------------------------------------------------------------------------------------------------------
#  MinGW runtime libraries
# ----------------------------------------------------------------------------------------------------------------

cd mingw-build
../mingw-w64-v3.1.0/configure --build=`../binutils-2.24/config.guess` --host=x86_64-w64-mingw32 \
	--enable-lib32 --with-sysroot=/jenkins-worker/mingw --prefix=/jenkins-worker/mingw/x86_64-w64-mingw32 \
	--with-crt
make
make install
cd ..

# ----------------------------------------------------------------------------------------------------------------
#  GCC
# ----------------------------------------------------------------------------------------------------------------

cd gcc-build
make
make install
cd ..

# ----------------------------------------------------------------------------------------------------------------
#  CMake (not cross-platform)
# ----------------------------------------------------------------------------------------------------------------

mkdir -p cmake-build
cd cmake-build
../cmake-2.8.12.2/configure --prefix=/jenkins-worker
make -j 3
make install
cd ..

export PATH="/jenkins-worker/bin:$PATH"

mkdir -p /jenkins-worker/cmake
cp -f mingw32.cmake /jenkins-worker/cmake/
cp -f mingw64.cmake /jenkins-worker/cmake/

# ----------------------------------------------------------------------------------------------------------------
#  zlib
# ----------------------------------------------------------------------------------------------------------------

mkdir -p zlib-build
cd zlib-build
rm -rf *
cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_TOOLCHAIN_FILE=/jenkins-worker/cmake/mingw32.cmake \
	-DCMAKE_INSTALL_PREFIX=/jenkins-worker/mingw/win32 ../zlib-1.2.8
make
make install
cd ..

cd zlib-build
rm -rf *
cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_TOOLCHAIN_FILE=/jenkins-worker/cmake/mingw64.cmake \
	-DCMAKE_INSTALL_PREFIX=/jenkins-worker/mingw/win64 ../zlib-1.2.8
make
make install
cd ..

ln -fs libzlib.dll.a /jenkins-worker/mingw/win32/lib/libz.a
ln -fs libzlib.dll.a /jenkins-worker/mingw/win64/lib/libz.a

# ----------------------------------------------------------------------------------------------------------------
#  OpenSSL
# ----------------------------------------------------------------------------------------------------------------

clean_openssl()
{
	make clean
	rm -f test/dummytest.exe crypto/Makefile.tmp krb5.h crypto/comp/Makefile.tmp crypto/aes/aes-586.s \
		crypto/bf/bf-586.s crypto/bn/bn-586.s crypto/bn/co-586.s crypto/bn/x86-mont.s crypto/camellia/cmll-x86.s \
		crypto/des/crypt586.s crypto/des/des-586.s crypto/md5/md5-586.s crypto/rc4/rc4-586.s \
		crypto/ripemd/rmd-586.s crypto/sha/sha1-586.s crypto/sha/sha256-586.s crypto/sha/sha512-586.s \
		crypto/uplink-cof.s crypto/whrlpool/wp-mmx.s crypto/x86cpuid.s
	git checkout tools/c_rehash crypto/opensslconf.h apps/CA.pl Makefile.bak Makefile apps/Makefile \
		crypto/Makefile crypto/aes/Makefile crypto/asn1/Makefile crypto/bio/Makefile crypto/bn/Makefile \
		crypto/buffer/Makefile crypto/cms/Makefile crypto/conf/Makefile crypto/des/Makefile crypto/dh/Makefile \
		crypto/dsa/Makefile crypto/dso/Makefile crypto/ec/Makefile crypto/ecdh/Makefile crypto/engine/Makefile \
		crypto/err/Makefile crypto/evp/Makefile crypto/hmac/Makefile crypto/lhash/Makefile \
		crypto/objects/Makefile crypto/ocsp/Makefile crypto/opensslconf.h crypto/pem/Makefile \
		crypto/pkcs12/Makefile crypto/pkcs7/Makefile crypto/pqueue/Makefile crypto/rand/Makefile \
		crypto/rc4/Makefile crypto/rsa/Makefile crypto/sha/Makefile crypto/stack/Makefile crypto/ts/Makefile \
		crypto/txt_db/Makefile crypto/ui/Makefile crypto/x509/Makefile crypto/x509v3/Makefile \
		engines/Makefile test/Makefile crypto/Makefile.save crypto/aes/Makefile.save crypto/bn/Makefile.save \
		crypto/buffer/Makefile.save crypto/des/Makefile.save crypto/dh/Makefile.save crypto/dsa/Makefile.save \
		crypto/dso/Makefile.save crypto/ec/Makefile.save crypto/ecdh/Makefile.save crypto/engine/Makefile.save \
		crypto/hmac/Makefile.save crypto/objects/Makefile.save crypto/rc4/Makefile.save crypto/rsa/Makefile.save \
		crypto/sha/Makefile.save crypto/bf/Makefile.save crypto/camellia/Makefile.save crypto/cast/Makefile.save \
		crypto/comp/Makefile.save crypto/ecdsa/Makefile.save crypto/idea/Makefile.save crypto/krb5/Makefile.save \
		crypto/md4/Makefile.save crypto/md5/Makefile.save crypto/mdc2/Makefile.save crypto/rc2/Makefile.save \
		crypto/ripemd/Makefile.save crypto/seed/Makefile.save crypto/whrlpool/Makefile.save \
		engines/ccgost/Makefile.save ssl/Makefile.save
}

mkdir -p openssl-1.0.0l
cd openssl-1.0.0l
clean_openssl
export WINDRES_TARGET=--target=pe-i386
./Configure --cross-compile-prefix="x86_64-w64-mingw32-" --prefix=/jenkins-worker/mingw/win32 \
	-m32 -I/jenkins-worker/mingw/win32/include -L/jenkins-worker/mingw/win32/lib \
	mingw zlib shared
make depend
make
make install
clean_openssl
mv -f /jenkins-worker/mingw/win32/lib/libssl.a /jenkins-worker/mingw/win32/lib/libsslstatic.a
mv -f /jenkins-worker/mingw/win32/lib/libcrypto.a /jenkins-worker/mingw/win32/lib/libcryptostatic.a
mv -f /jenkins-worker/mingw/win32/lib/libssl.dll.a /jenkins-worker/mingw/win32/lib/libssl.a
mv -f /jenkins-worker/mingw/win32/lib/libcrypto.dll.a /jenkins-worker/mingw/win32/lib/libcrypto.a
ln -s libssl.a /jenkins-worker/mingw/win32/lib/libssl.dll.a
ln -s libcrypto.a /jenkins-worker/mingw/win32/lib/libcrypto.dll.a
cd ..

mkdir -p openssl-1.0.0l
cd openssl-1.0.0l
clean_openssl
export WINDRES_TARGET=--target=pe-x86-64
./Configure --cross-compile-prefix="x86_64-w64-mingw32-" --prefix=/jenkins-worker/mingw/win64 \
	-m64 -I/jenkins-worker/mingw/win64/include -L/jenkins-worker/mingw/win64/lib \
	mingw64 zlib shared
make depend
make
make install
clean_openssl
mv -f /jenkins-worker/mingw/win64/lib/libssl.a /jenkins-worker/mingw/win64/lib/libsslstatic.a
mv -f /jenkins-worker/mingw/win64/lib/libcrypto.a /jenkins-worker/mingw/win64/lib/libcryptostatic.a
mv -f /jenkins-worker/mingw/win64/lib/libssl.dll.a /jenkins-worker/mingw/win64/lib/libssl.a
mv -f /jenkins-worker/mingw/win64/lib/libcrypto.dll.a /jenkins-worker/mingw/win64/lib/libcrypto.a
ln -s libssl.a /jenkins-worker/mingw/win64/lib/libssl.dll.a
ln -s libcrypto.a /jenkins-worker/mingw/win64/lib/libcrypto.dll.a
cd ..

# ----------------------------------------------------------------------------------------------------------------
#  ICU
# ----------------------------------------------------------------------------------------------------------------

mkdir -p icu-build
cd icu-build
rm -rf *
../icu4c-52_1/source/configure
make
cd ..

mkdir -p icu-cross-build
cd icu-cross-build
rm -rf *
CC=x86_64-w64-mingw32-gcc CXX=x86_64-w64-mingw32-g++ CFLAGS="-O2 -m32" CXXFLAGS="-O2 -m32 --std=c++03" \
CPPFLAGS="-m32" AR=x86_64-w64-mingw32-ar RANLIB=x86_64-w64-mingw32-ranlib \
	../icu4c-52_1/source/configure --prefix=/jenkins-worker/mingw/win32 --disable-static --enable-shared=yes \
	--enable-tests=no --enable-samples=no --enable-dyload=no --enable-strict=no --enable-extras=no \
	--host=i686-w64-mingw32 --with-cross-build=`pwd`/../icu-build
make -j 3
make install
cd ..

cd icu-cross-build
rm -rf *
CC=x86_64-w64-mingw32-gcc CXX=x86_64-w64-mingw32-g++ CFLAGS="-O2 -m64" CXXFLAGS="-O2 -m64 --std=c++03" \
CPPFLAGS="-m64" AR=x86_64-w64-mingw32-ar RANLIB=x86_64-w64-mingw32-ranlib \
	../icu4c-52_1/source/configure --prefix=/jenkins-worker/mingw/win64 --disable-static --enable-shared=yes \
	--enable-tests=no --enable-samples=no --enable-dyload=no --enable-strict=no --enable-extras=no \
	--host=x86_64-w64-mingw32 --with-cross-build=`pwd`/../icu-build
make -j 3
make install
cd ..

for lib in icudt icuin icuio icule iculx icutest icutu icuuc; do
	ln -fs ${lib}.dll.a /jenkins-worker/mingw/win32/lib/lib${lib}.a
	ln -fs ${lib}.dll.a /jenkins-worker/mingw/win64/lib/lib${lib}.a
done

# ----------------------------------------------------------------------------------------------------------------
#  ANGLE
# ----------------------------------------------------------------------------------------------------------------

git submodule update angle

cd angle
patch -p1 -i ../angle-patch/angle.patch
../angle-patch/make_commit_h.sh
cd ..

mkdir -p angle-build
cd angle-build
rm -rf *
cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_TOOLCHAIN_FILE=`pwd`/../mingw32.cmake \
	-DCMAKE_INSTALL_PREFIX=/jenkins-worker/mingw/win32 ../angle-patch
make -j 3
make install
cd ..

cd angle-build
rm -rf *
cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_TOOLCHAIN_FILE=`pwd`/../mingw64.cmake \
	-DCMAKE_INSTALL_PREFIX=/jenkins-worker/mingw/win64 ../angle-patch
make -j 3
make install
cd ..

rm -f angle/src/common/commit.h

ln -fs libEGL.dll.a /jenkins-worker/mingw/win32/lib/libEGL.a
ln -fs libGLESv2.dll.a /jenkins-worker/mingw/win32/lib/libGLESv2.a
ln -fs libEGL.dll.a /jenkins-worker/mingw/win64/lib/libEGL.a
ln -fs libGLESv2.dll.a /jenkins-worker/mingw/win64/lib/libGLESv2.a
