// Created by web3d3v on 23/04/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation
import SwiftKeccak

struct Web3SecretStorage: Codable {
    var crypto: Web3SecretStorage.Crypto
    var id: String
    var version: Int
    var address: String?
    var type: Web3SecretStorage.ItemType

    init(
        crypto: Crypto,
        id: String,
        version: Int,
        address: String? = nil,
        type: ItemType = .key
    ) {
        self.crypto = crypto
        self.id = id
        self.version = version
        self.address = address
        self.type = type
    }
}

// MARK: - Encrypt

extension Web3SecretStorage {

    static func encrypt(
        _ data: Data,
        password: String,
        address: String? = nil,
        n: Int = 262144, // 1 << 18
        p: Int = 1,
        r: Int = 8,
        c: Int = 262144, // 1 << 18
        dkLen: Int = 32,
        cipher: String = "aes-128-ctr"
    ) throws -> Web3SecretStorage {
        let id = UUID().uuidString
        let salt = try Data.secRandom(32)
        let iv = try Data.secRandom(16)

        // TODO: Switch to scrypt
        guard let dKey = pbkdf2(password, salt: salt, length: dkLen, rounds: c) else {
            throw SError.pbkdf2FailedToDeriveKey
        }

        let encryptionKey = dKey[0...15]
        let tail16Byte = dKey[(dKey.count - 16)...(dKey.count - 1)]
        let cypher = try aesCTR(key: encryptionKey, data: data, iv: iv)
        let mac = keccak256(Data().appending(tail16Byte).appending(cypher))
        return Web3SecretStorage(
            crypto: .init(
                ciphertext: cypher.hexString(),
                cipher: cipher,
                cipherParams: .init(iv: iv.hexString()),
                kdf: "pbkdf2",
                kdfParams: .init(
                    c: c,
                    dkLen: dkLen,
                    prf: "hmac-sha256",
                    salt: salt.hexString()
                ),
                mac: mac.hexString()
            ),
            id: id,
            version: 3,
            address: address
        )
    }
}

// MARK: - Decrypt

extension Web3SecretStorage {

    func decrypt(_ password: String) throws -> Data {

        guard let salt = Data.fromHexString(crypto.kdfParams.salt),
              let c = crypto.kdfParams.c,
              let iv = Data.fromHexString(crypto.cipherParams.iv),
              let data = Data.fromHexString(crypto.ciphertext),
              let mac = Data.fromHexString(crypto.mac)
            else {
            throw SError.failedToLoadData
        }

        // TODO: Switch to scrypt
        guard let dKey = pbkdf2(
            password,
            salt: salt ?? (try? Data.secRandom(crypto.kdfParams.dkLen)) ?? Data(),
            length: crypto.kdfParams.dkLen,
            rounds: crypto.kdfParams.c ?? 0
        ) else {
            throw SError.pbkdf2FailedToDeriveKey
        }

        let encryptionKey = dKey[0...15]
        let tail16Byte = dKey[(dKey.count - 16)...(dKey.count - 1)]

        guard mac == keccak256(Data().appending(tail16Byte).appending(data)) else {
            throw SError.wrongPassword
        }

        return try aesCTR(key: encryptionKey, data: data, iv: iv, op: .decrypt)
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

    struct KdfParams: Codable {
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

// MARK: - Kind

extension Web3SecretStorage {

    enum ItemType: Int, Codable {
        case key
        case entropy
    }
}

// MARK: - Error

extension Web3SecretStorage {

    enum SError: Error {
        case pbkdf2FailedToDeriveKey
        case failedToLoadData
        case wrongPassword
    }
}
