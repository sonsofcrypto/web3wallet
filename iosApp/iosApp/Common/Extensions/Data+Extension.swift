// Created by web3d3v on 14/04/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation
import web3walletcore

// MARK: - Hex string

extension Data {
    
    func hexString() -> String {
        reduce("") { $0 + String(format: "%02x", $1) }
    }
}

extension Data {
    var pngImage: UIImage? { .init(data: self) }
}

// MARK: - Appending

extension Data {

    func appending(_ data: Data) -> Data {
        var output = Data(self)
        output.append(data)
        return output
    }
}

// MARK: - Kotlin bytes array

extension Data {

    func byteArray() -> KotlinByteArray {
        return ExtensionsKt.byteArrayFrom(data: self)
    }
}
