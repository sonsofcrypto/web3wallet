# Audit notes

## Disclaimer
All of the code is work in progress. Written in a rush to get MVP ready as fast as possible. Started out as demo running all on mocks. For purpose to have something to show off for IDO. Much of the mocks is still there. Most fleshed out part are modules having to do with onboarding / seed creation. Sum total of ~ 3 weeks of development, ~160k lines of code.

## Overview
iOS, Android and browser extension web3 wallets app. All UI is native with shared library that handles all crypto stuff and as much of shared business logic as possible.

## Apps
For MVP focusing on iOS only ([repo](https://github.com/sonsofcrypto/web3wallet/tree/master/ios)). App uses [Viper](https://www.objc.io/issues/13-architecture/viper/), iOS version [Clean architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html). Extremely modular. Lands itself well if to fast development, all the dependencies are injected. Allows us to mock and test easily. As well swap out any modules for white label product. It also scales well to large engineering teams. Most fleshed out parts are the onboarding / seed creation. There are number of onboarding flows supported. Can be configures in settings. All the UI follow UIKit best practices. There is a lot of custom containers, interactions code

## Crypto
Just last week we have hit a road block and had to rip out shared web3 lib written in GO. Right now [Bip39](https://github.com/bitcoin/bips/blob/master/bip-0039.mediawiki) is implemented natively in [Swift here](https://github.com/sonsofcrypto/web3wallet/blob/master/ios/web3wallet/Common/CryptoUtils/Bip39.swift). It might still be worth looking at [Go implementation here](https://github.com/sonsofcrypto/bip39/blob/master/bip39.go).

[Web3 Secret Storage](https://github.com/ethereum/wiki/wiki/Web3-Secret-Storage-Definition) is implemented in [Swift here](https://github.com/sonsofcrypto/web3wallet/blob/master/ios/web3wallet/Common/Services/KeyStore/SecretStorage.swift). And again in [go here](https://github.com/sonsofcrypto/keyStore/blob/master/keyStoreItem.go).

Go implementations use same crypto functions as Geth. Swift implementations are [wrappers](https://github.com/sonsofcrypto/web3wallet/blob/master/ios/web3wallet/Common/CryptoUtils/CryptoUtils.swift) around `CommonCrypto`, Apple's system crypto library. With exception of `Keccak256` as `CommonCrypto` does not support it. For purposes of the demo we are using `SwiftKeccak` framework. I would not want to ship that to prod. For key derivation Go uses `scrypt`, Swift uses `pbkdf2` as `CommonCryto` does not support `scrypt`. 

Ultimate goal now is to use Kotlin Multi Platform for shared library. With C implementation of crypto primitives.


## Closing
Just want to reiterate one more, this is very much MVP work in progress 
 