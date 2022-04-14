// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

struct KeyStoreItem {
    let uuid: UUID
    var name: String
    var sortOrder: Int
    var iCouldBackup: Bool
    var saltMnemonic: Bool
    var mnemonicSalt: String
    var passwordType: PasswordType
    var password: String
    var allowPswdUnlockWithFaceId: Bool
    let creationDate: Date
    var modification: Date
    let encryptedSigner: String
    let mnemonic: String
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
    }
}

// MARK: - Codable

extension KeyStoreItem: Codable {}

// MARK: - Random

extension KeyStoreItem {

    static func rand() -> KeyStoreItem {
        return KeyStoreItem(
            uuid: UUID(),
            name: "",
            sortOrder: 0,
            iCouldBackup: true,
            saltMnemonic: false,
            mnemonicSalt: "",
            passwordType: .bio,
            password: "",
            allowPswdUnlockWithFaceId: true,
            creationDate: Date(),
            modification: Date(),
            encryptedSigner: "",
            mnemonic: "strategy edge trash series dad tiny couch since witness box unveil timber"
        )
    }

    static func blank() -> KeyStoreItem {
        return KeyStoreItem(
            uuid: UUID(),
            name: "",
            sortOrder: 0,
            iCouldBackup: true,
            saltMnemonic: false,
            mnemonicSalt: "",
            passwordType: .bio,
            password: "",
            allowPswdUnlockWithFaceId: true,
            creationDate: Date(),
            modification: Date(),
            encryptedSigner: "",
            mnemonic: ""
        )
    }
}