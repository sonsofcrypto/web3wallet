#!/bin/zsh

gomobile bind -v -target=android -o ./../web3lib_utils/src/androidMain/libs/CoreCrypto.aar ./
gomobile bind -v -target=ios -o ./CoreCrypto.xcframework ./

SRC="@import Foundation;"
DST="#import <Foundation\/Foundation.h>"

sed -i -- "s/$SRC/$DST/g" \
  ./CoreCrypto.xcframework/ios-arm64/CoreCrypto.framework/Headers/CoreCrypto.objc.h

sed -i -- "s/$SRC/$DST/g" \
  ./CoreCrypto.xcframework/ios-arm64/CoreCrypto.framework/Headers/Universe.objc.h

sed -i -- "s/$SRC/$DST/g" \
  ./CoreCrypto.xcframework/ios-arm64_x86_64-simulator/CoreCrypto.framework/Headers/CoreCrypto.objc.h

sed -i -- "s/$SRC/$DST/g" \
  ./CoreCrypto.xcframework/ios-arm64_x86_64-simulator/CoreCrypto.framework/Headers/Universe.objc.h

rm ./CoreCrypto.xcframework/ios-arm64/CoreCrypto.framework/Headers/CoreCrypto.objc.h--
rm ./CoreCrypto.xcframework/ios-arm64/CoreCrypto.framework/Headers/Universe.objc.h--
rm ./CoreCrypto.xcframework/ios-arm64_x86_64-simulator/CoreCrypto.framework/Headers/CoreCrypto.objc.h--
rm ./CoreCrypto.xcframework/ios-arm64_x86_64-simulator/CoreCrypto.framework/Headers/Universe.objc.h--

rm -rf ./../web3lib_utils/src/iosMain/libs/CoreCrypto/ios-arm64/CoreCrypto.framework
rm -rf ./../web3lib_utils/src/iosMain/libs/CoreCrypto/ios-arm64_x86_64-simulator/CoreCrypto.framework
rm -rf ./../web3lib_core/src/iosMain/libs/CoreCrypto/ios-arm64/CoreCrypto.framework
rm -rf ./../web3lib_core/src/iosMain/libs/CoreCrypto/ios-arm64_x86_64-simulator/CoreCrypto.framework
rm -rf ./../web3lib_keyStore/src/iosMain/libs/CoreCrypto/ios-arm64/CoreCrypto.framework
rm -rf ./../web3lib_keyStore/src/iosMain/libs/CoreCrypto/ios-arm64_x86_64-simulator/CoreCrypto.framework
rm -rf ./../web3lib_provider/src/iosMain/libs/CoreCrypto/ios-arm64/CoreCrypto.framework
rm -rf ./../web3lib_provider/src/iosMain/libs/CoreCrypto/ios-arm64_x86_64-simulator/CoreCrypto.framework
rm -rf ./../web3lib/src/iosMain/libs/CoreCrypto/ios-arm64/CoreCrypto.framework
rm -rf ./../web3lib/src/iosMain/libs/CoreCrypto/ios-arm64_x86_64-simulator/CoreCrypto.framework

cp -r ./CoreCrypto.xcframework/ios-arm64/CoreCrypto.framework \
  ./../web3lib_utils/src/iosMain/libs/CoreCrypto/ios-arm64/CoreCrypto.framework

cp -r ./CoreCrypto.xcframework/ios-arm64_x86_64-simulator/CoreCrypto.framework \
  ./../web3lib_utils/src/iosMain/libs/CoreCrypto/ios-arm64_x86_64-simulator/CoreCrypto.framework

cp -r ./CoreCrypto.xcframework/ios-arm64/CoreCrypto.framework \
  ./../web3lib_core/src/iosMain/libs/CoreCrypto/ios-arm64/CoreCrypto.framework

cp -r ./CoreCrypto.xcframework/ios-arm64_x86_64-simulator/CoreCrypto.framework \
  ./../web3lib_core/src/iosMain/libs/CoreCrypto/ios-arm64_x86_64-simulator/CoreCrypto.framework

cp -r ./CoreCrypto.xcframework/ios-arm64/CoreCrypto.framework \
  ./../web3lib_keyStore/src/iosMain/libs/CoreCrypto/ios-arm64/CoreCrypto.framework

cp -r ./CoreCrypto.xcframework/ios-arm64_x86_64-simulator/CoreCrypto.framework \
  ./../web3lib_keyStore/src/iosMain/libs/CoreCrypto/ios-arm64_x86_64-simulator/CoreCrypto.framework

cp -r ./CoreCrypto.xcframework/ios-arm64/CoreCrypto.framework \
  ./../web3lib_provider/src/iosMain/libs/CoreCrypto/ios-arm64/CoreCrypto.framework

cp -r ./CoreCrypto.xcframework/ios-arm64_x86_64-simulator/CoreCrypto.framework \
  ./../web3lib_provider/src/iosMain/libs/CoreCrypto/ios-arm64_x86_64-simulator/CoreCrypto.framework

cp -r ./CoreCrypto.xcframework/ios-arm64/CoreCrypto.framework \
  ./../web3lib/src/iosMain/libs/CoreCrypto/ios-arm64/CoreCrypto.framework

cp -r ./CoreCrypto.xcframework/ios-arm64_x86_64-simulator/CoreCrypto.framework \
  ./../web3lib/src/iosMain/libs/CoreCrypto/ios-arm64_x86_64-simulator/CoreCrypto.framework


