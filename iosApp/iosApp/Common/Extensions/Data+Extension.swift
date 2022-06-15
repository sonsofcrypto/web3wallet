// Created by web3d3v on 14/04/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation
import web3lib

// MARK: - Hex string

extension Data {
    
    func hexString() -> String {
        reduce("") { $0 + String(format: "%02x", $1) }
    }

    static func fromHexString(_ str: String?) -> Data? {
        guard let str = str?.stripHexPrefix() else {
            return nil
        }
        var bytes = Array<UInt8>()
        var strBuffer = ""

        for char in str {
            strBuffer.append(char)
            if strBuffer.count == 2 {
                bytes.append(UInt8(strBuffer, radix: 16)!)
                strBuffer = ""
            }
        }

        return Data(bytes)
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
        return ExtensionsKt.byteArray(self)
    }
}
