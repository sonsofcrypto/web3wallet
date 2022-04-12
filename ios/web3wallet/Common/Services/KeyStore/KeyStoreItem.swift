// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

struct KeyStoreItem {
    let uuid: UUID
    var name: String
    var sortOrder: Int
    var iCouldBackup: Bool
    let creationDate: Date
    var modification: Date
    let encryptedSigner: String
    let mnemonic: String
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
            creationDate: Date(),
            modification: Date(),
            encryptedSigner: "",
            mnemonic: "strategy edge trash series dad tiny couch since witness box unveil timber"
        )
    }
}