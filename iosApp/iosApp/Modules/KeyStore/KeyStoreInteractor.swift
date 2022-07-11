// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation
import web3lib

protocol KeyStoreInteractor: AnyObject {
    var selected: KeyStoreItem? {set get}
    var items: [KeyStoreItem] { get }
    var isEmpty: Bool { get }

    func item(at idx: Int) -> KeyStoreItem?
    func index(of keyStoreItem: KeyStoreItem?) -> Int?

    func add(item: KeyStoreItem, password: String, secretStorage: SecretStorage) throws
    func remove(item: KeyStoreItem)

    /// Generates new `KeyStoreItem` but does not save it to `KeyStore`
    func generateNewKeyStoreItem(_ type: KeyStoreItem.Type_) -> KeyStoreItem
    func reset() throws
}

// MARK: - DefaultKeyStoreInteractor

final class DefaultKeyStoreInteractor {

    var selected: KeyStoreItem? {
        get { keyStoreService.selected }
        set { keyStoreService.selected = newValue }
    }

    var items: [KeyStoreItem] {
        keyStoreService.items()
    }

    var isEmpty: Bool {
        items.isEmpty
    }

    private var keyStoreService: KeyStoreService

    init(_ keyStoreService: KeyStoreService) {
        self.keyStoreService = keyStoreService
    }
}

// MARK: - DefaultKeyStoreInteractor

extension DefaultKeyStoreInteractor: KeyStoreInteractor {

    func item(at idx: Int) -> KeyStoreItem? {
        items[safe: idx]
    }
    func index(of keyStoreItem: KeyStoreItem?) -> Int? {
        items.firstIndex(where: { $0.uuid == keyStoreItem?.uuid })
    }

    func add(item: KeyStoreItem, password: String, secretStorage: SecretStorage) throws {
        try keyStoreService.add(item: item, password: password, secretStorage: secretStorage)
    }

    func remove(item: KeyStoreItem) {
        keyStoreService.remove(item: item)
    }

    /// Generates new `KeyStoreItem` but does not save it to `KeyStore`
    func generateNewKeyStoreItem(_ type: KeyStoreItem.Type_) -> KeyStoreItem {
        return .init(
            uuid: UUID().uuidString,
            name: "",
            sortOrder: (items.last?.sortOrder ?? 0) + 100,
            type: type,
            passUnlockWithBio: true,
            iCloudSecretStorage: true,
            saltMnemonic: false,
            passwordType: .pass,
            derivationPath: "m/44'/60'/0'/0/0", // TODO: Get default derivations path from wallet
            addresses: [:]
        )
    }

    func reset() throws {
        items.forEach { keyStoreService.remove(item: $0) }
    }
}
