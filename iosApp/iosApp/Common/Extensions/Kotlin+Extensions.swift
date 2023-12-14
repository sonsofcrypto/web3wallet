// Created by web3d3v on 13/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation
import web3walletcore

extension KotlinError: Swift.Error {}

extension Network {
    static func ethereum() -> Network { Network.Companion().ethereum()}
    static func goerli() -> Network { Network.Companion().goerli() }
    static func sepolia() -> Network { Network.Companion().sepolia() }
}

extension Formatters {
    static var currency: CurrencyFormatter { Formatters.Companion().currency }
    static var fiat: FiatFormatter { Formatters.Companion().fiat }
    static var pct: PctFormatter { Formatters.Companion().pct }
    static var date: DateFormatter { Formatters.Companion().date }
}

extension Data {
    func byteArray() -> KotlinByteArray {
        ExtensionsKt.byteArrayFrom(data: self)
    }
}

extension Int {

    var kotlinInt: KotlinInt { KotlinInt(int: self.int32) }
}
