#!/usr/bin/env bash

set -ex

# /opt/hostedtoolcache/ndk/${NDK_VERSION_NAME_R28}/x64
#
# The following envs are injected by CI.
# export ANDROID_NDK='/usr/local/lib/android/sdk/ndk/28.0.13004108'
# export ANDROID_NDK_HOME='/usr/local/lib/android/sdk/ndk/28.0.13004108'
# export ANDROID_NDK_LATEST_HOME='/usr/local/lib/android/sdk/ndk/28.0.13004108'
# export ANDROID_NDK_ROOT='/usr/local/lib/android/sdk/ndk/28.0.13004108'

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
