# web3lib
 
### NOTE: Currently under active development. MVP within 4 weeks

`web3lib` is written in [Go](https://go.dev) with binding and wrappers for 
[Swift](https://www.swift.org), [Kotlin](https://kotlinlang.org) and 
[TypeScript](https://www.typescriptlang.org). Handles all web3 needs. Creating 
and managing wallets, signing transactions, connecting to networks, interacting 
with smart contracts.

Supported networks:
- Ethereum

Soon to be supported:
- Arbitrum one
- Polka Dot

Long term want to support as many L1s & L2s as posible


## Compilation instructions

- Setup [GoLang](https://go.dev/doc/install) environment. 
- Install gomobile
```
$ go install golang.org/x/mobile/cmd/gomobile@latest
$ go install golang.org/x/mobile/cmd/gobind@latest
$ gomobile init
```
- get dependencies `cd ./go && go get -v`
- build Swift `gomobile bind -v -target=ios -o ./../swift/web3lib.xcframework ./`
- build Kotlin `gomobile bind -v -o ./../kotlin/web3lib.aar -target=android ./`
- build for TypeScript, coming soon™

NOTE: If you are seeing `no exported names in the package`, either moving 
repo to `$GOPATH/src`, or following steps [here](https://github.com/golang/go/issues/37961#issuecomment-673854585) should fix it.
