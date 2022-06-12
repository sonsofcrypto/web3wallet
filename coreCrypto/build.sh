#!/bin/zsh

gomobile bind -v -o ./../web3lib_crypto/src/androidMain/libs/CoreCrypto.aar -target=android ./
gomobile bind -v -target=ios -o ./../iosApp/Frameworks/CoreCrypto.xcframework ./
