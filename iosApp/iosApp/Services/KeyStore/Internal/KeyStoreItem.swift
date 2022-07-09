// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

struct KeyStoreItem {
    let uuid: UUID

    var mnemonicSalt: String
    var password: String
    var mnemonic: String

    var name: String
    var saltMnemonic: Bool
    var passwordType: PasswordType
    var passUnlockWithBio: Bool
    var iCloudSecretStorage: Bool

    var secretStorage: SecretStorage? = nil
}

// MARK: - Convenience

extension KeyStoreItem {

    var id: String {
        uuid.uuidString
    }

    static func from(
        _ secretStorage: SecretStorage,
        password: String? = nil
    ) -> KeyStoreItem {
        var mnemonic = ""

        if !secretStorage.w3wParams.saltMnemonic, let password = password,
           let entropy = try? secretStorage.decrypt(password),
           let mnemonicWords = (try? Bip39(entropy))?.mnemonic {
            mnemonic = mnemonicWords.joined(separator: " ")
        }

        return .init(
            uuid: UUID(uuidString: secretStorage.id) ?? UUID(),
            mnemonicSalt: "",
            password: password ?? "",
            mnemonic:  mnemonic,
            name: secretStorage.w3wParams.name,
            saltMnemonic: secretStorage.w3wParams.saltMnemonic,
            passwordType: .from(secretStorage.w3wParams.passwordType),
            passUnlockWithBio: secretStorage.w3wParams.passUnlockWithBio,
            iCloudSecretStorage: secretStorage.w3wParams.iCloudSecretStorage,
            secretStorage: secretStorage
        )
    }

    mutating func updateSecretStorage(_ password: String) throws {
        let words = mnemonic.split(separator: " ").map { String($0) }
        // TODO: Validate word count
        self.secretStorage = try SecretStorage.encrypt(
            try Bip39(mnemonic: words).entropy(),
            password: password,
            w3wParams: .init(
                name: name,
                saltMnemonic: saltMnemonic,
                passwordType: passwordType.w3wParams,
                passUnlockWithBio: passUnlockWithBio,
                iCloudSecretStorage: iCloudSecretStorage
            )
        )
    }
}

// MARK: - Random

extension KeyStoreItem {

    static func rand() -> KeyStoreItem {
        // TODO: Throw and try to recover upstream
        let mnemonic = try! Bip39(.entropy128).mnemonic
        let password = (try! Data.secRandom(16)).hexString()

        return .init(
            uuid: UUID(),
            mnemonicSalt: "",
            password: password,
            mnemonic: mnemonic.joined(separator: " "),
            name: "Main Wallet 1",
            saltMnemonic: false,
            passwordType: .bio,
            passUnlockWithBio: false,
            iCloudSecretStorage: true,
            secretStorage: nil
        )
    }

    static func blank() -> KeyStoreItem {
        let mnemonic = try! Bip39(.entropy128).mnemonic
        return .init(
            uuid: UUID(),
            mnemonicSalt: "",
            password: "",
            mnemonic: mnemonic.joined(separator: " "),
            name: "",
            saltMnemonic: false,
            passwordType: .bio,
            passUnlockWithBio: false,
            iCloudSecretStorage: true,
            secretStorage: nil
        )
    }
}

// MARK: - PasswordType

extension KeyStoreItem {

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

        var w3wParams: SecretStorage.W3WParams.PasswordType {
            switch self {
            case .pin:
                 return .pin
            case .password:
                return .password
            case .bio:
                return .bio
            }
        }

        static func from(
            _ w3wParams: SecretStorage.W3WParams.PasswordType
        ) -> PasswordType {
            switch w3wParams {
            case .pin:
                return .pin
            case .password:
                return .password
            case .bio:
                return .bio
            }
        }
    }
}

// MARK: - Codable

extension KeyStoreItem: Codable {}
