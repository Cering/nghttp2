#!/bin/bash

curPath=$(cd $(dirname $0); pwd)
srcPath=${curPath}/../..
outPath=${curPath}/output_ios
buildPath=${curPath}/build_ios
sdkName=iphoneos
sdkPath=$(xcrun -sdk ${sdkName} --show-sdk-path)

set -e

buildIOS()
{
    arch=$1
    outPath_arch="${outPath}/${arch}"
    buildPath_arch="${buildPath}/${arch}"

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
          -DCMAKE_OSX_SYSROOT="${sdkPath}" \
          -DCMAKE_OSX_ARCHITECTURES="${arch}" \
          -DCMAKE_OSX_DEPLOYMENT_TARGET="8.0" \
          -DCMAKE_C_FLAGS="-pipe -Os -gdwarf-2 -fembed-bitcode"

    cmake --build ${buildPath_arch} --target clean -v
    cmake --build ${buildPath_arch} --config Release -v
    cmake --build ${buildPath_arch} --target install -v
}

rm -rf ${outPath}
buildIOS "armv7"
buildIOS "arm64"

#mkdir -p -v ${outPath}/lib
#lipo ${outPath}/armv7/lib/libnghttp2.a ${outPath}/arm64/lib/libnghttp2.a -create -output ${outPath}/lib/libnghttp2.a
#cp -rfv ${outPath}/armv7/include ${outPath}/
#xcrun -sdk ${sdkName} lipo -info ${outPath}/lib/*.a
