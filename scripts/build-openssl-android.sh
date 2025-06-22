#!/usr/bin/env bash

set -ex

/opt/hostedtoolcache/ndk/r28/x64

USE_PREBUILT_LIBS="false"

if [ "$1" == "--use-prebuilt-libs" ];then
  USE_PREBUILT_LIBS="true"
fi

if [ -d "$ANDROID_NDK_HOME" ];then
  echo "NDK exists"
else
  echo "NDK NOT EXISTS"
  exit 1
fi

if [ -d '/usr/local/lib/android/sdk/ndk/' ];then
  echo "Default NDKs: "
  ls '/usr/local/lib/android/sdk/ndk/'
fi

LIBS_ROOT="third-party-libs/"

if [ ! -d "${LIBS_ROOT}" ];then
  mkdir "${LIBS_ROOT}"
  mkdir "${LIBS_ROOT}/arm64-v8a"
  mkdir "${LIBS_ROOT}/armeabi-v7a"
fi


if [ "${USE_PREBUILT_LIBS}" == "true" ];then
  echo "using flutter_avif Android libs, skip building process."
  echo "make sure you are not using prebuilt libs when releasing new versions, otherwise F-Droid build are broken."

  LIBS_REPO="third-party"

  git clone https://github.com/KDAB/android_openssl/ "${LIBS_REPO}" -b 6b9ba2b962e96f437550b5197c130225dd416ddf

  # "${LIBS_REPO}/ssl_3/${ARCH}/*.a" -> "${LIBS_ROOT}/${ARCH}/"
  cp "${LIBS_REPO}/ssl_3/arm64-v8a/libssl.a" "${LIBS_ROOT}/arm64-v8a/libssl.a"
  cp "${LIBS_REPO}/ssl_3/arm64-v8a/libssl_3.so" "${LIBS_ROOT}/arm64-v8a/libssl.so"
  cp "${LIBS_REPO}/ssl_3/arm64-v8a/libssl_3.so" "${LIBS_ROOT}/arm64-v8a/ssl.lib"
  cp "${LIBS_REPO}/ssl_3/arm64-v8a/libcrypto.a" "${LIBS_ROOT}/arm64-v8a/libcrypto.a"
  cp "${LIBS_REPO}/ssl_3/arm64-v8a/libcrypto_3.so" "${LIBS_ROOT}/arm64-v8a/libcrypto.so"
  cp "${LIBS_REPO}/ssl_3/arm64-v8a/libcrypto_3.so" "${LIBS_ROOT}/arm64-v8a/crypto.lib"

  cp "${LIBS_REPO}/ssl_3/armeabi-v7a/libssl.a" "${LIBS_ROOT}/armeabi-v7a/libssl.a"
  cp "${LIBS_REPO}/ssl_3/armeabi-v7a/libssl_3.so" "${LIBS_ROOT}/armeabi-v7a/libssl.so"
  cp "${LIBS_REPO}/ssl_3/armeabi-v7a/libssl_3.so" "${LIBS_ROOT}/armeabi-v7a/ssl.lib"
  cp "${LIBS_REPO}/ssl_3/armeabi-v7a/libcrypto.a" "${LIBS_ROOT}/armeabi-v7a/libcrypto.a"
  cp "${LIBS_REPO}/ssl_3/armeabi-v7a/libcrypto_3.so" "${LIBS_ROOT}/armeabi-v7a/libcrypto.so"
  cp "${LIBS_REPO}/ssl_3/armeabi-v7a/libcrypto_3.so" "${LIBS_ROOT}/armeabi-v7a/crypto.lib"

  exit 0
fi

AVIF_ROOT="packages/flutter_avif"
AVIF_ANDROID_JNILIBS_DIR="${AVIF_ROOT}/flutter_avif_android/android/src/main/jniLibs"
