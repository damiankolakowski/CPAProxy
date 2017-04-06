#!/bin/bash
set -e

export OPENSSL_VERSION="1.0.2h"
export LIBEVENT_VERSION="2.0.22-stable"
export TOR_VERSION="0.2.9.8"

TOPDIR=$(pwd)

rm -rf "{TOPDIR}/output" || true

mkdir -p "${TOPDIR}/output/final/include"
mkdir -p "${TOPDIR}/output/final/lib"

#### BUILD OPENSSL LIB

echo "Building openssl..."

curl -O "https://www.openssl.org/source/openssl-${OPENSSL_VERSION}.tar.gz"
tar zxf "openssl-${OPENSSL_VERSION}.tar.gz"
rm -rf "openssl-${OPENSSL_VERSION}.tar.gz"

cd "openssl-${OPENSSL_VERSION}"

rm -rf "${TOPDIR}/output/openssl" || true
mkdir -p "${TOPDIR}/output/openssl"

./Configure darwin64-x86_64-cc enable-ec_nistp_64_gcc_128 no-shared --openssldir="${TOPDIR}/output/openssl"

make depend
make
make install_sw

cp "${TOPDIR}/output/openssl/lib/libcrypto.a" "${TOPDIR}/output/final/lib"
cp "${TOPDIR}/output/openssl/lib/libssl.a" "${TOPDIR}/output/final/lib"
cp -R "${TOPDIR}/output/openssl/include/openssl" "${TOPDIR}/output/final/include"

cd ..

### BUILD LIBEVENT LIB

echo "Building libevent..."

ARCHIVE_NAME="libevent-${LIBEVENT_VERSION}"

curl -LO "https://github.com/libevent/libevent/releases/download/release-${LIBEVENT_VERSION}/${ARCHIVE_NAME}.tar.gz"
tar zxf "${ARCHIVE_NAME}.tar.gz"
rm -rf "${ARCHIVE_NAME}.tar.gz"

cd "${ARCHIVE_NAME}"

rm -rf "${TOPDIR}/output/libevent" || true
mkdir -p "${TOPDIR}/output/libevent"

echo "${TOPDIR}/patches/libevent-configure.diff"

patch -p3 < "${TOPDIR}/patches/libevent-configure.diff" configure

./configure --disable-shared --enable-static --disable-debug-mode \
   --prefix="${TOPDIR}/output/libevent" \
   CFLAGS="-I${TOPDIR}/output/openssl/include" \
   LDFLAGS="-L${TOPDIR}/output/openssl/lib" \
   LIBS="-lssl -lcrypto"

make

make install

cp "${TOPDIR}/output/libevent/lib/libevent.a" "${TOPDIR}/output/final/lib"
cp "${TOPDIR}/output/libevent/lib/libevent_core.a" "${TOPDIR}/output/final/lib"
cp "${TOPDIR}/output/libevent/lib/libevent_extra.a" "${TOPDIR}/output/final/lib"
cp "${TOPDIR}/output/libevent/lib/libevent_openssl.a" "${TOPDIR}/output/final/lib"
cp "${TOPDIR}/output/libevent/lib/libevent_pthreads.a" "${TOPDIR}/output/final/lib"
cp -R ${TOPDIR}/output/libevent/include/* "${TOPDIR}/output/final/include"

cd ..

#### BUILD TOR LIB

echo "Building tor..."

curl -O "https://dist.torproject.org/tor-${TOR_VERSION}.tar.gz"

tar zxf "tor-${TOR_VERSION}.tar.gz"
rm -rf "tor-${TOR_VERSION}.tar.gz"

cd "tor-${TOR_VERSION}"

rm -rf "${TOPDIR}/output/tor"
mkdir -p "${TOPDIR}/output/tor"

patch -p3 < "${TOPDIR}/patches/tor-nsenviron.diff"
patch -p3 < "${TOPDIR}/patches/tor-ptrace.diff"
patch -p3 < "${TOPDIR}/patches/configure.ac.event-compat.diff" configure.ac
patch -p1 < "${TOPDIR}/patches/tor-nosigpipe.diff"
patch -p1 < "${TOPDIR}/patches/tor-reload.diff"
patch -p1 < "${TOPDIR}/patches/tor-rephist.diff"

./configure --enable-static-openssl --enable-static-libevent \
	--prefix=${TOPDIR}/output/tor \
	--with-openssl-dir=${TOPDIR}/output/openssl \
	--with-libevent-dir=${TOPDIR}/output/libevent \
	--disable-asciidoc --disable-transparent --disable-tool-name-check

make

cp "src/common/libor-crypto.a" "${TOPDIR}/output/final/lib"
cp "src/common/libor-event.a" "${TOPDIR}/output/final/lib"
cp "src/common/libor.a" "${TOPDIR}/output/final/lib"
cp "src/common/libcurve25519_donna.a" "${TOPDIR}/output/final/lib"
cp "src/common/libor-ctime.a" "${TOPDIR}/output/final/lib"
cp "src/or/libtor.a" "${TOPDIR}/output/final/lib"
cp "src/trunnel/libor-trunnel.a" "${TOPDIR}/output/final/lib"
cp "src/ext/ed25519/donna/libed25519_donna.a" "${TOPDIR}/output/final/lib"
cp "src/ext/ed25519/ref10/libed25519_ref10.a" "${TOPDIR}/output/final/lib"
cp "src/ext/keccak-tiny/libkeccak-tiny.a" "${TOPDIR}/output/final/lib"

# Copy the micro-revision.i file that defines the Tor version
cp "micro-revision.i" "${TOPDIR}/output/final/include"

# Copy the geoip files
cp "src/config/geoip" "${TOPDIR}/output/final/"
cp "src/config/geoip6" "${TOPDIR}/output/final/"

cd ..

cp "tor_cpaproxy.h" "${TOPDIR}/output/final/include"