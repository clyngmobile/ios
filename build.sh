#!/bin/bash

#clear

rm -rf ./out
mkdir ./out

xcodebuild -project ./corelib/ClyngMobile.xcodeproj -configuration Release -sdk iphoneos6.0
xcodebuild -project ./corelib/ClyngMobile.xcodeproj -configuration Release -sdk iphonesimulator6.0 "ARCHS=i386" "VALID_ARCHS=i386" build

lipo -output ./out/libClyngMobile.a -create ./corelib/build/Release-iphoneos/libClyngMobile.a ./corelib/build/Release-iphonesimulator/libClyngMobile.a

xcodebuild -project ./demoapp/demo.xcodeproj -configuration Release -sdk iphoneos6.0
xcodebuild -project ./demoapp/demo.xcodeproj -configuration Release -sdk iphonesimulator6.0 "ARCHS=i386" "VALID_ARCHS=i386" build

OUTDIR=$(pwd)
OUTDIR="${OUTDIR}/out"

PRODUCTDIR=./demoapp/Build/Release-iphoneos
TARGET=demo
IDENTITY="iPhone Distribution: Rule Grid, Inc."
PROVISIONING_PROFILE="~/Library/MobileDevice/Provisioning\ Profiles/6B39FBD0-F45E-4E20-A9F5-BCAC0507045E.mobileprovision"

/usr/bin/xcrun -sdk iphoneos PackageApplication -v "${PRODUCTDIR}/${TARGET}.app" -o "${OUTDIR}/${TARGET}.ipa" --sign "${IDENTITY}" --embed "${PROVISONING_PROFILE}"

#cp ./corelib/build/Release-iphoneos/libClyngMobile.a ./out
#cp ./corelib/build/Release-iphonesimulator/libClyngMobile.a ./out


cp -r corelib/ClyngMobile.bundle out/

cp corelib/ClyngMobile/CMClient.h out/
