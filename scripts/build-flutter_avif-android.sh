#!/usr/bin/env bash

set -ex

export ANDROID_HOME='/usr/local/lib/android/sdk'
export ANDROID_NDK='/usr/local/lib/android/sdk/ndk/28.0.13004108'
export ANDROID_NDK_HOME='/usr/local/lib/android/sdk/ndk/28.0.13004108'
export ANDROID_NDK_LATEST_HOME='/usr/local/lib/android/sdk/ndk/28.0.13004108'
export ANDROID_NDK_ROOT='/usr/local/lib/android/sdk/ndk/28.0.13004108'
export ANDROID_SDK_ROOT='/usr/local/lib/android/sdk'

if [ -d '/usr/local/lib/android/sdk/ndk/28.0.13004108' ];then
  echo "NDK r28 exists"
else
  echo "NDK r28 NOT EXISTS"
  exit 1
fi

if [ -d '/usr/local/lib/android/sdk/ndk/27.2.12479018' ];then
  echo "NDK r27c exists"
  echo "delete r27c"
  mv '/usr/local/lib/android/sdk/ndk/27.2.12479018' '/usr/local/lib/android/sdk/ndk/27.2.12479018.bak'
fi

AVIF_ROOT="packages/flutter_avif"
AVIF_ANDROID_JNILIBS_DIR="${AVIF_ROOT}/flutter_avif_android/android/src/main/jniLibs"

find "${AVIF_ANDROID_JNILIBS_DIR}" -type f -name "*.so" -delete
ls -R "${AVIF_ANDROID_JNILIBS_DIR}"

echo "building flutter_avif Android libs ..."
pushd "${AVIF_ROOT}/rust/"
make android
popd
echo "building flutter_avif Android libs ... OK!"

ls -R "${AVIF_ANDROID_JNILIBS_DIR}"
find "${AVIF_ANDROID_JNILIBS_DIR}" -type f -name "*.so" -exec md5sum {} +
