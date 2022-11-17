# web3wallet
 
### NOTE: Currently under active development.

# corecrypto

`CoreCrypto` is written in [Go](https://go.dev) with binding and wrappers for
[Swift](https://www.swift.org), [Kotlin](https://kotlinlang.org) and
[TypeScript](https://www.typescriptlang.org). Provides all the core crypto
primitives. Uses the very same libraries as [Geth](https://github.com/ethereum/go-ethereum).

### Compilation instructions

- Setup [GoLang](https://go.dev/doc/install) environment.
- Install gomobile
```
$ go install golang.org/x/mobile/cmd/gomobile@latest
$ go install golang.org/x/mobile/cmd/gobind@latest
$ gomobile init
```
- get dependencies `go get -v`
- build Swift `gomobile bind -v -target=ios -o ./../swift/web3lib.xcframework ./`
- build Kotlin ` gomobile bind -v -o ./../web3lib_crypto/src/androidMain/libs/CoreCrypto.aar -target=android ./`
- build for TypeScript, coming soon™

NOTE: If you are seeing `no exported names in the package`, either moving
repo to `$GOPATH/src`, or following steps [here](https://github.com/golang/go/issues/37961#issuecomment-673854585) 
should fix it.

# web3lib
Aims to be alternative / equivalent of [ethers](https://docs.ethers.io/v5/) / 
[web3js](https://web3js.readthedocs.io) written using [Kotlin multiplatform]
(https://kotlinlang.org/docs/multiplatform.html). Library in under heavy 
active development. 
- build config file `./gradlew generateBuildKonfig` 
- see all available tasks `./gradlew tasks` 

# web3Wallet
Multichain, cross-platform, open source, web3 wallet. Uses clean 
architecture. All the shared code is in web3walletcore shared library. Each 
supported platform provides native UI.

## androidApp
Compile using Android Studio

## iosApp
Build web3walletcore library ```./gradlew :web3walletcore:assembleXCFramework```
and run normally from Xcode. Alternatively add iosApp configuration in Android 
Studio and run from there

### Run iOS tests

In `./web3lib/build.gradle.kts` find `runIosTests` task set 
`simulatorId.set("...")` then run `./gradlew runIosTests --info`

For faster per module execution run manually. First build test binary:
```
./gradlew :web3lib:cleanIosSimulatorArm64Test :web3lib:iosSimulatorArm64Test --info
```
Get simulator UUID by running `xcrun simctl list`. Boot simulator 
`xcrun simctl boot ${UUID}`. Run tests:
```
xcrun simctl spawn ${UUID} web3lib/build/bin/iosSimulatorArm64/debugTest/test.kexe
```

## jsApp
soon™
