// Created by web3d3v on 23/04/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation
import web3lib

// https://github.com/ethereum/wiki/wiki/Web3-Secret-Storage-Definition#pbkdf2-sha-256
struct SecretStorage: Codable {
    let crypto: SecretStorage.Crypto
    let id: String
    let version: Int
    let address: String?
    let w3wParams: W3WParams

    init(
        crypto: Crypto,
        id: String,
        version: Int,
        address: String? = nil,
        w3wParams: W3WParams = .default()
    ) {
        self.crypto = crypto
        self.id = id
        self.version = version
        self.address = address
        self.w3wParams = w3wParams
    }

    func data() throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return try encoder.encode(self)
    }
}

// MARK: - Encrypt

extension SecretStorage {

    static func encrypt(
        _ data: Data,
        password: String,
        address: String? = nil,
        n: Int = 262144, // 1 << 18
        p: Int = 1,
        r: Int = 8,
        c: Int = 262144, // 1 << 18
        dkLen: Int = 32,
        cipher: String = "aes-128-ctr",
        w3wParams: W3WParams = .default()
    ) throws -> SecretStorage {
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
        let mac = HashKt.keccak256(data: Data().appending(tail16Byte).appending(cypher).byteArray()).toDataFull()
        return SecretStorage(
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
            address: address,
            w3wParams: w3wParams
        )
    }
}

// MARK: - Decrypt

extension SecretStorage {

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

        guard mac == HashKt.keccak256(data: Data().appending(tail16Byte).appending(data).byteArray()).toDataFull() else {
            throw SError.wrongPassword
        }

        return try aesCTR(key: encryptionKey, data: data, iv: iv, op: .decrypt)
    }
}

// MARK: - Crypto

extension SecretStorage {

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

extension SecretStorage.Crypto {

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

extension SecretStorage.Crypto {

    struct CipherParams: Codable {
        var iv: String
    }
}

// MARK: - W3WParams

extension SecretStorage {

    struct W3WParams: Codable {

        let name: String
        let saltMnemonic: Bool
        let passwordType: PasswordType
        let passUnlockWithBio: Bool
        let iCloudSecretStorage: Bool

        static func `default`() -> W3WParams {
            .init(
                name: "",
                saltMnemonic: false,
                passwordType: .bio,
                passUnlockWithBio: false,
                iCloudSecretStorage: true
            )
        }
    }
}

// MARK: - ItemType

extension SecretStorage.W3WParams {

    enum ItemType: Int, Codable {
        case key
        case entropy
    }
}

// MARK: - PasswordType

extension SecretStorage.W3WParams {

    enum PasswordType: Int, Codable, CaseIterable {
        case pin
        case password
        case bio

        var localizedDescription: String {
            switch self {
            case .pin:
                return Localized("newMnemonic.passType.pin")
            case .password:
                return Localized("newMnemonic.passType.password")
            case .bio:
                return Localized("newMnemonic.passType.faceId")
            }
        }
    }
}

// MARK: - Error

extension SecretStorage {

    enum SError: Error {
        case pbkdf2FailedToDeriveKey
        case failedToLoadData
        case wrongPassword
    }
}
