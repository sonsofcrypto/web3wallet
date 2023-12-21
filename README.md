<img align="right" src="bundledAssets/images/logo.png"/>

# web3wallet

by cypherpunks for cypherpunks

by degens for degens

for more info see [sonsofcrypto.com](https://sonsofcrypto.com)

[Download Beta Builds](CHANGELOG.md)

[Download on AppStore](https://apps.apple.com/us/app/web3wallet-by-sons-of-crypto-%CE%BE/id6464587288)

NOTE: Currently under active development.

&nbsp;

# coreCrypto

`CoreCrypto` is written in [Go](https://go.dev) with binding and wrappers for
[Swift](https://www.swift.org), [Kotlin](https://kotlinlang.org) and
[TypeScript](https://www.typescriptlang.org). Provides all the core crypto
primitives (cryptographically secure randomness, ECDSA, AES, hashing functions).
Uses the very same libraries as [Geth](https://github.com/ethereum/go-ethereum).

### Prerequisites

- Setup [GoLang](https://go.dev/doc/install) environment.
  - Install gomobile
  ```
  $ go install golang.org/x/mobile/cmd/gomobile@latest
  $ go install golang.org/x/mobile/cmd/gobind@latest
  $ gomobile init
  ```
  - make sure `$GOPATH` & go bin is in `$PATH`
  ```
  # Example
  export GOPATH="$HOME/Development/go"
  export PATH=$PATH:$GOPATH/bin
  export GO111MODULE=auto
  ```
- Setup Java  
  - Install Open JDK 17.0.8.1. Easiest via Android Studio/Project Structure/Gradle
  Settings
  - Make sure `$JAVA_HOME` is set and bin folder is in `$PATH`
  ```
  # Example Linux
  export JAVA_HOME=/usr/lib/jvm/default
  export PATH="/usr/lib/jvm/default/bin:$PATH"
  
  #Example macOS
  export JAVA_HOME="/Users/anon/Library/Java/JavaV¡irtualMachines/temurin-17.0.8.1/Contents/Home"
  export PATH="/Users/anon/Library/Java/JavaVirtualMachines/temurin-17.0.8.1/Contents/Home/bin:$PATH"
  export CPPFLAGS="-I/Users/anon/Library/Java/JavaVirtualMachines/temurin-17.0.8.1/Contents/Home/include"
  ```
- Setup Android SDK & NDK
  - Easiest via Android Studio/Tools/SDK Manager Settings
  - Export `$ANDROID_SDK_HOME` & `$ANDROID_NDK_HOME`
  ```
  # Example
  export ANDROID_SDK_HOME="$HOME/Development/.android"
  export ANDROID_NDK_HOME="$HOME/Development/.android/ndk-bundle"
  ```
- Local Properties
  - Create `local.properties` file in root folder if not preset
  - Grade sync (& build of everything apart from `coreCrypto`) will fail if 
  following properties are not set.
  ```
  com.sonsofcrypto.alchemyKey=
  com.sonsofcrypto.etherscanKey=
  com.sonsofcrypto.pokt.portalId=
  com.sonsofcrypto.pokt.publicKey=
  com.sonsofcrypto.pokt.secretKey=
  com.sonsofcrypto.moralisKey=
  com.sonsofcrypto.testMnemonic=
  ```

### Compilation instructions
- `cd coreCrypto` folder
- run `.build.sh` currently builds:
  - android `coreCrypto.aar` & `coreCrypto-sources.jar`
  - iOS `CoreCrypto.framework` for simulators & devices
  - host OS unit test `coreCrypto.jar` (currently supports linux & macOS)
  - build for TypeScript, coming soon™

SEE: `coreCrypto/build.sh` on how to build of `coreCrypto` for individual 
platforms. 

NOTE: If you are seeing `no exported names in the package`, either moving
repo to `$GOPATH/src`, or following steps [here](https://github.com/golang/go/issues/37961#issuecomment-673854585) 
should fix it.

# web3lib
Aims to be alternative / equivalent of [ethers](https://docs.ethers.io/v5/) / 
[web3js](https://web3js.readthedocs.io) written in 
[Kotlin multiplatform](https://kotlinlang.org/docs/multiplatform.html). Library in under heavy 
active development. 
- build config file `./gradlew generateBuildKonfig` 
- see all available tasks `./gradlew tasks`
- android compiles automatically when building androidApp
- iOS run `./gradlew :web3lib:assembleXCFramework --rerun-tasks --info`
  Only need to use `--rerun-tasks` once initially and after each cache clean. 
  Due to the bug in CInterop (fails to created targets for all platforms 
  otherwise). 
- run android / host OS unit test `./gradlew :web3lib:cleanTestDebugUnitTest :web3lib:testDebugUnitTest`
- run iOS tests unit test `./gradlew :web3lib:cleanIosSimulatorArm64Test :web3lib:iosSimulatorArm64Test`
  See iosApp for more details how to run tests.

# web3WalletCore
Multichain, cross-platform, open source, web3 wallet. Uses clean 
architecture. All the shared code is in web3walletcore shared library. Each 
supported platform provides native UI.
- see all available tasks `./gradlew tasks`
- android compiles automatically when building androidApp
- iOS run `./gradlew :web3walletcore:assembleXCFramework --rerun-tasks --info`
  Only need to use `--rerun-tasks` once initially and after each cache clean.
  Due to the bug in CInterop (fails to created targets for all platforms
  otherwise).
- run android / host OS unit test `./gradlew :web3walletcore:cleanTestDebugUnitTest :web3walletcore:testDebugUnitTest`
- run iOS tests unit test `./gradlew :web3walletcore:cleanIosSimulatorArm64Test :web3walletcore:iosSimulatorArm64Test`
  See iosApp for more details how to run tests.

## androidApp
- compile using Android Studio
- see all available tasks `./gradlew tasks`

## iosApp
- iOS run `./gradlew :web3walletcore:assembleXCFramework --rerun-tasks --info`
  Only need to use `--rerun-tasks` once initially and after each cache clean.
  Due to the bug in CInterop (fails to created targets for all platforms
  otherwise). and run normally from Xcode.
- alternatively add `iosApp` configuration in Android Studio. No need to build
  web3walletcore XCFramework. Order of magnitude FASTER compiles. Currently 
  debug run is not working when running from Android Studio
- run iOS test
  - in `./web3lib/build.gradle.kts` find `runIosTests` task set 
  `simulatorId.set("...")` then run `./gradlew runIosTests --info`
  - for faster per module execution run manually. First build test binary:
  ```
  ./gradlew :web3lib:cleanIosSimulatorArm64Test :web3lib:iosSimulatorArm64Test --info
  ```
  - get simulator UUID by running `xcrun simctl list`. Boot simulator 
  `xcrun simctl boot ${UUID}`. Run tests:
  ```
  xcrun simctl spawn ${UUID} web3lib/build/bin/iosSimulatorArm64/debugTest/test.kexe
  ```
  to get UUID of booted simulator `xcrun simctl list | grep Booted`

## jsApp
soon™

## miscellaneous

### update resource
iOS, Android and unit test build expect resource files at different paths. 
Source truth lives in `buildedAssets` following command copies it to 
appropriate paths for all supported targets.    
```./gradlew updateResources --rerun --info```

### fenerate Android keys for local runs

```
keytool -genkey -v -keystore androidApp/debug.keystore -storepass android -alias androiddebugkey -keyalg RSA -keysize 2048 -validity 10000
keytool -genkey -v -keystore androidApp/release.jks -storepass android -alias androidreleasekey -keyalg RSA -keysize 2048 -validity 10000
```

### android studio notes
- Gradle 8.1.1
- Android Gradle Plugin 8.1.1
- Kotlin 1.9.21

## teaser 
<p align="center">
  <img src="bundledAssets/images/first_launch_teaser_7.gif"/>
  <br/><a href="https://sonsofcrypto.com">sonsofcrypto.com</a>
</p>

[//]: # (![web3wallet]&#40;iosApp/iosApp/Assets.xcassets/AppIcon.appiconset/w3w_logo_1024.png&#41;)
