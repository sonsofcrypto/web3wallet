// Created by web3d3v on 23/04/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

struct Web3SecretStorage {
    var crypto: Web3SecretStorage.Crypto
    var id: String
    var version: Int
    var address: String?

    init(crypto: Crypto, id: String, version: Int, address: String? = nil) {
        self.crypto = crypto
        self.id = id
        self.version = version
        self.address = address
    }
}

// MARK: - Crypto

extension Web3SecretStorage {

    struct Crypto: Codable {
        var ciphertext: String
        var cipher: String
        var cipherParams: CipherParams
        var kdf: String
        var kdfParams: KdfParams
        var mac: String
        var version: String?
    }
}

// MARK: - KdfParams

extension Web3SecretStorage.Crypto {

    struct KdfParams: Decodable, Encodable {
        var n: Int?
        var p: Int?
        var r: Int?
        var c: Int?
        var dkLen: Int
        var prf: String?
        var salt: String

        static func `default`(_ salt: Data) -> KdfParams {
            .init(
                n: 262144, // 1 << 18
                p: 1,
                r: 8,
                c: nil,
                dkLen: 32,
                prf: "hmac-sha256",
                salt: salt.hexString()
            )
        }
    }
}

// MARK: - CipherParams

extension Web3SecretStorage.Crypto {

    struct CipherParams: Codable {
        var iv: String
    }
}
