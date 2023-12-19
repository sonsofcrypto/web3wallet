#!/bin/zsh

# Android
echo "Building Android framework"
rm ./build/android/coreCrypto.aar
rm ./build/android/coreCrypto-sources.jar
gomobile bind -v -target=android -androidapi 19 -o ./build/android/coreCrypto.aar ./
echo "======================"
echo "Android framework done"

# iOS
if [[ "$OSTYPE" == "darwin"* ]]; then
  echo "Building iOS framework"
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

  DEF_FILE_CONTENT="language = Objective-C\npackage = CoreCrypto\nmodules = CoreCrypto"
  echo $DEF_FILE_CONTENT > ./build/ios/ios-arm64_x86_64-simulator/CoreCrypto.def
  echo $DEF_FILE_CONTENT > ./build/ios/ios-arm64/CoreCrypto.def

    echo "======================"
    echo "iOS framework done"
fi

# Host OS
echo "Building host OS framework (for tests)"
echo "======================"
gobind -lang=go,java -outdir=build/hostOS -classpath CoreCrypto .
cp supportFiles/go/* build/hostOS/src
rm build/hostOS/src/gobind/universe.h
rm build/hostOS/src/gobind/universe_android.h
rm build/hostOS/src/gobind/universe_android.c
rm build/hostOS/src/gobind/seq.h
rm build/hostOS/src/gobind/seq.go
rm build/hostOS/src/gobind/seq_android.h
rm build/hostOS/src/gobind/seq_android.c
rm build/hostOS/src/gobind/seq_android.go
rm build/hostOS/src/gobind/go_main.go
rm build/hostOS/src/gobind/coreCrypto.h
mv build/hostOS/src/gobind/coreCrypto_android.h build/hostOS/src/gobind/coreCrypto.h
grep -v "#include <android/log.h>" build/hostOS/src/gobind/coreCrypto_android.c > build/hostOS/src/gobind/coreCrypto.c
rm build/hostOS/src/gobind/coreCrypto_android.c
cp supportFiles/c/* build/hostOS/src/gobind

cd build/hostOS
export GOPATH="$(pwd):$GOPATH"
export GO111MODULE=auto
export GOARCH=amd64
export CGO_ENABLED=1
export GOOS=linux

if [[ "$OSTYPE" == "darwin"* ]]; then
  export GOOS=darwin
  export GOARCH=amd64

  if [[ $(arch) == 'arm64' ]]; then
    export GOARCH=arm64
  fi

  SEARCH="-I/usr/lib/jvm/default/include -I/usr/lib/jvm/default/include/linux"
  REPLACE="-I$JAVA_HOME/include -I$JAVA_HOME/include/darwin"
  ESCAPED_SEARCH=$(printf '%s\n' "$SEARCH" | sed -e 's/[]\/$*.^[]/\\&/g');
  ESCAPED_REPLACE=$(printf '%s\n' "$REPLACE" | sed -e 's/[]\/$*.^[]/\\&/g');
  sed -ie "s+$ESCAPED_SEARCH+$ESCAPED_REPLACE+" src/gobind/seq.go
fi

cd src
go build -v -buildmode=c-shared -o=../output/libgojni.so ./gobind
cd ../../..

rm build/hostOS/java/go/Seq.java
cp supportFiles/java/* build/hostOS/java/go/

cd build/hostOS/java
javac -d ../output -source 1.7 -target 1.7 -classpath CoreCrypto coreCrypto/CoreCrypto.java coreCrypto/Enode.java coreCrypto/Enodes.java coreCrypto/KeccakState.java coreCrypto/Node.java coreCrypto/NodeConfig.java coreCrypto/NodeInfo.java coreCrypto/PeerInfos.java go/Seq.java go/Universe.java go/error.java go/LoadJNI.java
cd ../output
mv libgojni.h go/libgojni.h
mv libgojni.so go/libgojni.so

zip -r ../coreCrypto.jar .
echo "======================"
echo "Host os framework done"
