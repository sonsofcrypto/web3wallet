#!/bin/zsh

# Android
rm ./build/android/coreCrypto.aar
rm ./build/android/coreCrypto-sources.jar
gomobile bind -v -target=android -androidapi 19 -o ./build/android/coreCrypto.aar ./

# iOS
if [[ "$OSTYPE" == "darwin"* ]]; then
  gomobile bind -v -target=ios -o ./build/ios/CoreCrypto.xcframework ./

  # Replace import syntax so that KMM can handle it
  SRC="@import Foundation;"
  DST="#import <Foundation\/Foundation.h>"

  sed -i -- "s/$SRC/$DST/g" \
    ./build/ios/CoreCrypto.xcframework/ios-arm64/CoreCrypto.framework/Headers/CoreCrypto.objc.h

  sed -i -- "s/$SRC/$DST/g" \
    ./build/ios/CoreCrypto.xcframework/ios-arm64/CoreCrypto.framework/Headers/Universe.objc.h

  sed -i -- "s/$SRC/$DST/g" \
    ./build/ios/CoreCrypto.xcframework/ios-arm64_x86_64-simulator/CoreCrypto.framework/Headers/CoreCrypto.objc.h

  sed -i -- "s/$SRC/$DST/g" \
    ./build/ios/CoreCrypto.xcframework/ios-arm64_x86_64-simulator/CoreCrypto.framework/Headers/Universe.objc.h

  # Remove renaming artifact files
  rm ./build/ios/CoreCrypto.xcframework/ios-arm64/CoreCrypto.framework/Headers/CoreCrypto.objc.h--
  rm ./build/ios/CoreCrypto.xcframework/ios-arm64/CoreCrypto.framework/Headers/Universe.objc.h--
  rm ./build/ios/CoreCrypto.xcframework/ios-arm64_x86_64-simulator/CoreCrypto.framework/Headers/CoreCrypto.objc.h--
  rm ./build/ios/CoreCrypto.xcframework/ios-arm64_x86_64-simulator/CoreCrypto.framework/Headers/Universe.objc.h--

  rm -rf ./build/ios/ios-arm64/CoreCrypto.framework
  rm -rf ./build/ios/ios-arm64_x86_64-simulator/CoreCrypto.framework

  # Split framework by architecture and move to dep files folder
  cp -r ./build/ios/CoreCrypto.xcframework/ios-arm64/CoreCrypto.framework \
    ./build/ios/ios-arm64/CoreCrypto.framework
  cp -r ./build/ios/CoreCrypto.xcframework/ios-arm64_x86_64-simulator/CoreCrypto.framework \
    ./build/ios/ios-arm64_x86_64-simulator/CoreCrypto.framework
fi