# CoreCrypto
 
### NOTE: Currently under active development.

`CoreCrypto` is written in [Go](https://go.dev) with binding and wrappers for 
[Swift](https://www.swift.org), [Kotlin](https://kotlinlang.org) and 
[TypeScript](https://www.typescriptlang.org). Provides all the core crypto
primitives. Uses same libraries as [Geth](https://github.com/ethereum/go-ethereum).

## Compilation instructions

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
repo to `$GOPATH/src`, or following steps [here](https://github.com/golang/go/issues/37961#issuecomment-673854585) should fix it.
