#!/bin/bash

curPath=$(cd $(dirname $0); pwd)
srcPath=${curPath}/../..
outPath=${curPath}/output_android
buildPath=${curPath}/build_android

set -e

buildAndroid()
{
    arch=$1
    outPath_arch="${outPath}/${arch}"
    buildPath_arch="${buildPath}/${arch}"
    export ANDROID_NDK=/opt/soft/android-ndk-r20b

    rm -rf ${buildPath_arch}
    mkdir -p ${buildPath_arch}
    cd ${buildPath_arch}
    cmake ${srcPath} \
          -DCMAKE_BUILD_TYPE="Release" \
          -DENABLE_SHARED_LIB=0 \
          -DENABLE_STATIC_LIB=1 \
          -DCMAKE_VERBOSE_MAKEFILE=1 \
          -DCMAKE_INSTALL_PREFIX="${outPath_arch}" \
          -DCMAKE_INSTALL_LIBDIR="${outPath_arch}/lib" \
          -DCMAKE_TOOLCHAIN_FILE=${ANDROID_NDK}/build/cmake/android.toolchain.cmake \
          -DANDROID_ABI=${arch} \
          -DANDROID_NATIVE_API_LEVEL=16 \
          -DCMAKE_C_FLAGS="-pipe -Os"

    cmake --build ${buildPath_arch} --target clean -v
    cmake --build ${buildPath_arch} --config Release -v
    cmake --build ${buildPath_arch} --target install -v
}

rm -rf ${outPath}
buildAndroid "armeabi-v7a"
buildAndroid "arm64-v8a"
buildAndroid "x86"
