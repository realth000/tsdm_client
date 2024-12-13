#!/usr/bin/env bash

set -ex

AVIF_ROOT="packages/flutter_avif"
AVIF_ANDROID_JNILIBS_DIR="${AVIF_ROOT}/flutter_avif_android/src/main/jniLibs"

find "${AVIF_ANDROID_JNILIBS_DIR}" -type f -name "*.so" -delete
ls -R "${AVIF_ANDROID_JNILIBS_DIR}"

echo "building flutter_avif Android libs ..."
pushd "${AVIF_ROOT}/rust/"
make android
popd
echo "building flutter_avif Android libs ... OK!"

ls -R "${AVIF_ANDROID_JNILIBS_DIR}"
find "${AVIF_ANDROID_JNILIBS_DIR}" -type f -name "*.so" -exec md5sum {} +
