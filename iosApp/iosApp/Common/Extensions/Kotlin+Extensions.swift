// Created by web3d3v on 13/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation
import web3walletcore

extension KotlinError: Error {}

extension Network {

    static func ethereum() -> Network {
        Network.Companion().ethereum()
    }

    static func goerli() -> Network {
        Network.Companion().goerli()
    }

    static func rinkeby() -> Network {
        Network.Companion().rinkeby()
    }

    static func ropsten() -> Network {
        Network.Companion().ropsten()
    }
}

func abiDecodeBigInt(_ value: String) -> BigInt {
    AbiEncodeKt.abiDecodeBigInt(value: value)
}

func abiDecodeAddress(_ value: String) -> Address.HexString {
    AbiEncodeKt.abiDecodeAddress(value: value)
}

func abiEncodeAddress(_ address: Address.HexString) -> KotlinByteArray {
    AbiEncodeKt.abiEncode(address: address)
}

func abiEncodeBigInt(_ bigInt: BigInt) -> KotlinByteArray {
    AbiEncodeKt.abiEncode(bigInt: bigInt)
}

func abiEncodeUInt(_ uint: UInt32) -> KotlinByteArray {
    AbiEncodeKt.abiEncode(uint: uint)
}
